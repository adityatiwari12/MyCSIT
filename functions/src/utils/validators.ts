import { ActivityType, CodingPlatform, CodingType, RegisterStudentRequest } from '../types';

const VALID_ACTIVITY_TYPES: ActivityType[] = [
  'hackathon', 'certification', 'research',
  'project', 'internship', 'achievement',
];

const VALID_CODING_PLATFORMS: CodingPlatform[] = [
  'leetcode', 'codeforces', 'codechef', 'other',
];

const VALID_CODING_TYPES: CodingType[] = [
  'milestone', 'contest', 'highValueProblem',
];

export class ValidationError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'ValidationError';
  }
}

export function validateRollNumber(raw: string): string {
  const trimmed = raw.trim().toLowerCase();
  if (!trimmed) throw new ValidationError('Roll number is required.');
  // Alphanumeric, 4–20 chars
  if (!/^[a-z0-9]{4,20}$/.test(trimmed)) {
    throw new ValidationError(
      'Roll number must be 4–20 alphanumeric characters.'
    );
  }
  return trimmed;
}

export function validateStudentRegistration(data: unknown): RegisterStudentRequest {
  if (typeof data !== 'object' || data === null) {
    throw new ValidationError('Invalid request payload.');
  }

  const req = data as Record<string, unknown>;

  const rollNumber = validateRollNumber(String(req.rollNumber ?? ''));

  const name = String(req.name ?? '').trim();
  if (!name || name.length < 2 || name.length > 80) {
    throw new ValidationError('Name must be 2–80 characters.');
  }

  const year = Number(req.year);
  if (!Number.isInteger(year) || year < 1 || year > 4) {
    throw new ValidationError('Year must be 1, 2, 3, or 4.');
  }

  const section = String(req.section ?? '').trim().toUpperCase();
  if (!['A', 'B', 'C', 'D', 'E'].includes(section)) {
    throw new ValidationError('Section must be A, B, C, D, or E.');
  }

  const password = String(req.password ?? '');
  if (password.length < 8) {
    throw new ValidationError('Password must be at least 8 characters.');
  }

  return { rollNumber, name, year, section, password };
}

export function validateActivityType(type: string): ActivityType {
  if (!VALID_ACTIVITY_TYPES.includes(type as ActivityType)) {
    throw new ValidationError(`Invalid activity type: ${type}`);
  }
  return type as ActivityType;
}

export function validateCodingPlatform(platform: string): CodingPlatform {
  if (!VALID_CODING_PLATFORMS.includes(platform as CodingPlatform)) {
    throw new ValidationError(`Invalid coding platform: ${platform}`);
  }
  return platform as CodingPlatform;
}

export function validateCodingType(type: string): CodingType {
  if (!VALID_CODING_TYPES.includes(type as CodingType)) {
    throw new ValidationError(`Invalid coding type: ${type}`);
  }
  return type as CodingType;
}

export function validateUrl(url: string, field: string): string {
  try {
    new URL(url);
    return url;
  } catch {
    throw new ValidationError(`${field} must be a valid URL.`);
  }
}
