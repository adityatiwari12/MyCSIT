-- ============================================================
-- MyCSIT: Server-side scoring, notifications, and triggers
-- Run this in your Supabase SQL Editor (Dashboard > SQL Editor)
-- ============================================================

-- ─── Score Recalculation Function ────────────────────────────────────────────
-- Weights: hackathon=35%, project=25%, academic=25%, coding=15%

CREATE OR REPLACE FUNCTION recalculate_score(p_user_id UUID)
RETURNS void AS $$
DECLARE
  v_hackathon_score NUMERIC := 0;
  v_project_score   NUMERIC := 0;
  v_academic_score  NUMERIC := 0;
  v_coding_score    NUMERIC := 0;
  v_total_score     NUMERIC := 0;
  v_cgpa            NUMERIC;
BEGIN
  -- ── Academic bucket: CGPA × 10, clamped 0–100 ──────────────────────────
  SELECT cgpa INTO v_cgpa
  FROM semesters
  WHERE user_id = p_user_id
  ORDER BY updated_at DESC
  LIMIT 1;

  IF v_cgpa IS NOT NULL THEN
    v_academic_score := LEAST(GREATEST(v_cgpa * 10.0, 0), 100);
  END IF;

  -- ── Hackathon bucket: hackathon/achievement/certification ───────────────
  -- Per-type points (full, 70%, 50% for 1st–3rd)
  WITH ranked AS (
    SELECT type,
           ROW_NUMBER() OVER (PARTITION BY type ORDER BY created_at ASC) AS rn
    FROM activities
    WHERE user_id = p_user_id
      AND status   = 'approved'
      AND is_deleted = false
      AND type IN ('hackathon', 'achievement', 'certification')
  ),
  weighted AS (
    SELECT CASE
             WHEN type = 'hackathon'     AND rn = 1 THEN 100.0
             WHEN type = 'hackathon'     AND rn = 2 THEN  70.0
             WHEN type = 'hackathon'     AND rn = 3 THEN  50.0
             WHEN type = 'achievement'   AND rn = 1 THEN  70.0
             WHEN type = 'achievement'   AND rn = 2 THEN  49.0
             WHEN type = 'achievement'   AND rn = 3 THEN  35.0
             WHEN type = 'certification' AND rn = 1 THEN  50.0
             WHEN type = 'certification' AND rn = 2 THEN  35.0
             WHEN type = 'certification' AND rn = 3 THEN  25.0
             ELSE 0
           END AS pts
    FROM ranked WHERE rn <= 3
  )
  SELECT LEAST(COALESCE(SUM(pts), 0), 100)
    INTO v_hackathon_score
  FROM weighted;

  -- ── Project bucket: project/internship/research ─────────────────────────
  WITH ranked AS (
    SELECT type,
           ROW_NUMBER() OVER (PARTITION BY type ORDER BY created_at ASC) AS rn
    FROM activities
    WHERE user_id = p_user_id
      AND status   = 'approved'
      AND is_deleted = false
      AND type IN ('project', 'internship', 'research')
  ),
  weighted AS (
    SELECT CASE
             WHEN type = 'project'    AND rn = 1 THEN  40.0
             WHEN type = 'project'    AND rn = 2 THEN  28.0
             WHEN type = 'project'    AND rn = 3 THEN  20.0
             WHEN type = 'internship' AND rn = 1 THEN  60.0
             WHEN type = 'internship' AND rn = 2 THEN  42.0
             WHEN type = 'internship' AND rn = 3 THEN  30.0
             WHEN type = 'research'   AND rn = 1 THEN  50.0
             WHEN type = 'research'   AND rn = 2 THEN  35.0
             WHEN type = 'research'   AND rn = 3 THEN  25.0
             ELSE 0
           END AS pts
    FROM ranked WHERE rn <= 3
  )
  SELECT LEAST(COALESCE(SUM(pts), 0), 100)
    INTO v_project_score
  FROM weighted;

  -- ── Coding bucket ───────────────────────────────────────────────────────
  -- milestone: problems-solved count (value = count), best milestone row
  -- contest:   contest rank (value = rank, lower = better), top 3
  -- highValueProblem: each entry = 1 hard problem solved (15 pts each, cap 60)
  WITH
  milestones AS (
    SELECT CASE
             WHEN value >= 500 THEN 50
             WHEN value >= 200 THEN 40
             WHEN value >= 100 THEN 30
             WHEN value >= 50  THEN 20
             WHEN value >= 10  THEN 10
             ELSE 0
           END AS pts
    FROM coding_activities
    WHERE user_id = p_user_id AND status = 'approved' AND is_deleted = false
      AND type = 'milestone'
    ORDER BY value DESC
    LIMIT 1
  ),
  contests AS (
    SELECT CASE
             WHEN value <=   100 THEN 50
             WHEN value <=   500 THEN 40
             WHEN value <=  1000 THEN 30
             WHEN value <=  5000 THEN 20
             ELSE 10
           END AS pts
    FROM coding_activities
    WHERE user_id = p_user_id AND status = 'approved' AND is_deleted = false
      AND type = 'contest'
    ORDER BY value ASC
    LIMIT 3
  ),
  high_value AS (
    SELECT LEAST(COUNT(*) * 15, 60) AS pts
    FROM coding_activities
    WHERE user_id = p_user_id AND status = 'approved' AND is_deleted = false
      AND type = 'highValueProblem'
  )
  SELECT LEAST(
    COALESCE((SELECT pts      FROM milestones), 0) +
    COALESCE((SELECT SUM(pts) FROM contests),   0) +
    COALESCE((SELECT pts      FROM high_value),  0),
    100
  ) INTO v_coding_score;

  -- ── Weighted total ───────────────────────────────────────────────────────
  v_total_score :=
    (v_hackathon_score * 0.35) +
    (v_project_score   * 0.25) +
    (v_academic_score  * 0.25) +
    (v_coding_score    * 0.15);

  -- ── Upsert score_cache ───────────────────────────────────────────────────
  INSERT INTO score_cache
    (user_id, total_score, hackathon_score, project_score, academic_score, coding_score, last_computed)
  VALUES
    (p_user_id, v_total_score, v_hackathon_score, v_project_score, v_academic_score, v_coding_score, NOW())
  ON CONFLICT (user_id) DO UPDATE SET
    total_score     = EXCLUDED.total_score,
    hackathon_score = EXCLUDED.hackathon_score,
    project_score   = EXCLUDED.project_score,
    academic_score  = EXCLUDED.academic_score,
    coding_score    = EXCLUDED.coding_score,
    last_computed   = EXCLUDED.last_computed;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ─── Notification Helper ───────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION create_notification(
  p_user_id UUID,
  p_title   TEXT,
  p_message TEXT
) RETURNS void AS $$
BEGIN
  INSERT INTO notifications (id, user_id, title, message, is_read, created_at)
  VALUES (gen_random_uuid(), p_user_id, p_title, p_message, false, NOW());
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ─── Trigger: Activity Status Change ─────────────────────────────────────────

CREATE OR REPLACE FUNCTION _on_activity_status_change()
RETURNS trigger AS $$
DECLARE
  v_msg TEXT;
BEGIN
  IF OLD.status IS DISTINCT FROM NEW.status AND NEW.status IN ('approved', 'rejected') THEN
    -- Recalculate score
    PERFORM recalculate_score(NEW.user_id);

    -- Insert notification
    IF NEW.status = 'approved' THEN
      v_msg := 'Your activity "' || NEW.title || '" was approved. It now counts toward your score.';
      PERFORM create_notification(NEW.user_id, 'Activity Approved', v_msg);
    ELSE
      v_msg := 'Your activity "' || NEW.title || '" was rejected.' ||
               CASE WHEN NEW.rejection_reason IS NOT NULL
                    THEN ' Reason: ' || NEW.rejection_reason
                    ELSE ''
               END;
      PERFORM create_notification(NEW.user_id, 'Activity Rejected', v_msg);
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_activity_status ON activities;
CREATE TRIGGER trg_activity_status
  AFTER UPDATE ON activities
  FOR EACH ROW EXECUTE FUNCTION _on_activity_status_change();

-- ─── Trigger: Coding Activity Status Change ───────────────────────────────────

CREATE OR REPLACE FUNCTION _on_coding_status_change()
RETURNS trigger AS $$
DECLARE
  v_msg TEXT;
BEGIN
  IF OLD.status IS DISTINCT FROM NEW.status AND NEW.status IN ('approved', 'rejected') THEN
    PERFORM recalculate_score(NEW.user_id);

    IF NEW.status = 'approved' THEN
      v_msg := 'Your coding entry "' || NEW.title || '" was approved.';
      PERFORM create_notification(NEW.user_id, 'Coding Entry Approved', v_msg);
    ELSE
      v_msg := 'Your coding entry "' || NEW.title || '" was rejected.' ||
               CASE WHEN NEW.rejection_reason IS NOT NULL
                    THEN ' Reason: ' || NEW.rejection_reason
                    ELSE ''
               END;
      PERFORM create_notification(NEW.user_id, 'Coding Entry Rejected', v_msg);
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_coding_status ON coding_activities;
CREATE TRIGGER trg_coding_status
  AFTER UPDATE ON coding_activities
  FOR EACH ROW EXECUTE FUNCTION _on_coding_status_change();

-- ─── Trigger: Semester Update (CGPA → score) ─────────────────────────────────

CREATE OR REPLACE FUNCTION _on_semester_change()
RETURNS trigger AS $$
BEGIN
  PERFORM recalculate_score(NEW.user_id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_semester_score ON semesters;
CREATE TRIGGER trg_semester_score
  AFTER INSERT OR UPDATE ON semesters
  FOR EACH ROW EXECUTE FUNCTION _on_semester_change();

-- ─── Trigger: Registration Approval/Rejection ─────────────────────────────────

CREATE OR REPLACE FUNCTION _on_registration_status_change()
RETURNS trigger AS $$
DECLARE
  v_title TEXT;
  v_msg   TEXT;
BEGIN
  IF OLD.status = 'pending' AND NEW.status IN ('active', 'rejected') THEN
    IF NEW.status = 'active' THEN
      v_title := 'Registration Approved';
      v_msg   := 'Welcome, ' || NEW.name || '! Your MyCSIT account is now active. Start building your profile by adding activities.';
    ELSE
      v_title := 'Registration Rejected';
      v_msg   := 'Your registration was not approved. Please contact your faculty coordinator for assistance.';
    END IF;
    PERFORM create_notification(NEW.id, v_title, v_msg);
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_registration_status ON users;
CREATE TRIGGER trg_registration_status
  AFTER UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION _on_registration_status_change();

-- ─── Grant execute permissions ────────────────────────────────────────────────
GRANT EXECUTE ON FUNCTION recalculate_score(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION create_notification(UUID, TEXT, TEXT) TO authenticated;
