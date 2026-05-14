# MyCSIT Project Context

## Project Overview

MyCSIT is a student productivity and achievement tracking platform for the CSIT Department at AITR (Academy of Innovation and Technology for Research). The app helps students track their activities, coding problems, academic performance, and achievements in a gamified manner.

## Technology Stack

### Frontend
- **Framework**: Flutter (Dart)
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **Authentication**: Custom mock authentication (Supabase paused)

### Backend (Currently Paused)
- **Database**: Supabase (PostgreSQL)
- **Authentication**: Supabase Auth
- **Status**: Supabase project is currently paused due to cost/usage reasons

### Current Architecture
- **Authentication**: Mock authentication system for development
- **Data Storage**: Local mock data services
- **State**: Riverpod providers for state management

## Project Structure

```
mycsit/
├── lib/
│   ├── core/
│   │   ├── components/          # Reusable UI components
│   │   │   ├── premium_card.dart
│   │   │   ├── premium_chip.dart
│   │   │   ├── premium_progress.dart
│   │   │   ├── premium_empty_state.dart
│   │   │   ├── animated_counter.dart
│   │   │   └── premium_bottom_nav.dart
│   │   ├── router/              # Navigation configuration
│   │   │   └── app_router.dart
│   │   └── theme/               # App theme and design system
│   │       └── app_theme.dart
│   ├── data/
│   │   ├── models/              # Data models
│   │   │   ├── user_model.dart
│   │   │   ├── activity_model.dart
│   │   │   ├── profile_model.dart
│   │   │   └── coding_model.dart
│   │   └── repositories/        # Data repositories
│   │       ├── auth_repository.dart
│   │       ├── profile_repository.dart
│   │       └── activity_repository.dart
│   ├── providers/              # Riverpod state providers
│   │   ├── auth_provider.dart
│   │   ├── user_provider.dart
│   │   └── mock_auth_provider.dart
│   ├── screens/                 # UI screens
│   │   ├── premium_*.dart       # Premium UI screens (new)
│   │   ├── functional_*.dart     # Functional screens (old)
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   └── splash_screen.dart
│   ├── services/                # Business logic services
│   │   ├── auth_service.dart
│   │   ├── mock_auth_service.dart
│   │   ├── mock_data_service.dart
│   │   ├── premium_mock_data.dart
│   │   └── scoring_service.dart
│   └── main.dart                # App entry point
├── database/                    # SQL files (Supabase - paused)
├── android/                     # Android configuration
├── ios/                         # iOS configuration
└── pubspec.yaml                 # Dependencies
```

## Key Features

### 1. Authentication System
- **Current**: Mock authentication with local providers
- **Previous**: Supabase Auth (paused)
- **Flow**: Login → Registration → Approval → Dashboard

### 2. Premium UI Redesign (Latest)
- **Design System**: Warm white background, coral/orange accent
- **Typography**: Google Fonts (Outfit + Inter)
- **Components**: Premium cards, chips, progress bars, empty states
- **Screens**:
  - Dashboard with hero profile card, activity heatmap, stats
  - Profile with badges, skills, coding platform stats
  - Activities timeline with filtering
  - Add Entry with interactive cards
  - Floating bottom navigation

### 3. Activity Tracking
- Workshops, seminars, competitions, projects
- Points-based gamification system
- Activity approval workflow (can be toggled)
- Rich activity cards with status indicators

### 4. Coding Platform Integration
- LeetCode, Codeforces, CodeChef tracking
- Problem submission tracking
- Rating and stats display
- Coding streaks and achievements

### 5. Academic Performance
- CGPA tracking
- Attendance monitoring
- Subject-wise grades
- Academic achievements

### 6. Profile Management
- Profile completeness visualization
- Social links (LinkedIn, GitHub, LeetCode, etc.)
- Skills and interests
- Achievement badges
- Academic summary

## Database Schema (Supabase - Paused)

### Tables
1. **auth_users** - User authentication data
2. **users** - User profile information
3. **activities** - Activity records
4. **coding_activities** - Coding problem submissions
5. **academic_records** - Academic performance data
6. **faculty** - Faculty information

### Key Relationships
- Users → Activities (one-to-many)
- Users → Coding Activities (one-to-many)
- Users → Academic Records (one-to-many)
- Faculty → Users (one-to-many for approval)

## Authentication Flow

### Current (Mock)
1. User enters email/password
2. MockAuthService validates credentials
3. User state updated via Riverpod
4. Navigation to dashboard

### Previous (Supabase - Paused)
1. User enters email/password
2. Supabase Auth handles authentication
3. User data stored in Supabase database
4. RLS policies for data security
5. Faculty approval workflow (optional)

## State Management

### Riverpod Providers
- `mockAuthStateNotifierProvider` - Authentication state
- `mockCurrentUserProvider` - Current user data
- `activitiesProvider` - Activities list
- `codingActivitiesProvider` - Coding activities
- `academicRecordsProvider` - Academic data

## Design System

### Colors
- Primary Accent: `#FF6B35` (Coral Orange)
- Secondary Accent: `#FF9F1C` (Warm Amber)
- Background: `#FAFAF9` (Warm White)
- Surface: `#FFFFFF` (Pure White)
- Text Primary: `#0F0F0F` (Deep Black)
- Text Secondary: `#525252` (Gray)

### Typography
- Display Font: Outfit (headings)
- Body Font: Inter (body text)

### Spacing
- xs: 4px, sm: 8px, md: 16px, lg: 24px, xl: 32px, 2xl: 48px

### Border Radius
- xs: 4px, sm: 8px, md: 12px, lg: 16px, xl: 20px, 2xl: 24px

## Dependencies

### Core
- flutter_riverpod: ^2.6.1 (State management)
- go_router: ^13.2.5 (Navigation)
- uuid: ^4.2.2 (UUID generation)
- intl: ^0.19.0 (Internationalization)

### UI (Premium)
- flutter_animate: ^4.5.2 (Animations)
- flutter_svg: ^2.3.0 (SVG support)
- fl_chart: ^0.66.2 (Charts)
- shimmer: ^3.0.0 (Loading skeletons)
- google_fonts: ^6.3.3 (Typography)
- percent_indicator: ^4.2.5 (Progress indicators)
- table_calendar: ^3.1.3 (Calendar)

### Utilities
- url_launcher: ^6.2.4 (URL launching)
- file_picker: ^8.3.7 (File picking)
- permission_handler: ^11.4.0 (Permissions)

## Development Status

### Completed
- ✅ Premium UI redesign
- ✅ Mock authentication system
- ✅ Activity tracking with points
- ✅ Coding platform integration
- ✅ Academic performance tracking
- ✅ Profile management
- ✅ Achievement badges system
- ✅ Responsive design
- ✅ APK build for release

### In Progress
- 🔄 Supabase integration (paused)
- 🔄 Real backend API integration
- 🔄 Push notifications
- 🔄 Leaderboard system

### Planned
- 📋 Dark mode support
- 📋 More chart types for analytics
- 📋 Notification badges
- 📋 Detailed activity analytics
- 📋 Social features (comments, likes)
- 📋 Offline mode

## Important Notes

### Supabase Status
**Supabase project is currently paused** due to cost/usage considerations. The app is currently running with:
- Mock authentication system
- Local data storage
- Mock data services

To resume Supabase integration:
1. Resume Supabase project
2. Update authentication service to use Supabase
3. Configure environment variables
4. Update RLS policies
5. Migrate local data to Supabase

### SQL Files
The `database/` folder contains SQL files for Supabase setup. These are currently not in use but kept for reference when Supabase is resumed.

### Premium UI
The premium UI is the current active design. Old functional screens are kept for reference but not in active use.

## Build Information

### Release APK
- Location: `build/app/outputs/flutter-apk/app-release.apk`
- Build Type: Release (optimized)
- Status: Successfully built

### Debug APK
- Location: `build/app/outputs/flutter-apk/app-debug.apk`
- Build Type: Debug (with debugging)

## Navigation Routes

### Current Routes
- `/premium` - Premium main screen (default)
- `/home` - Original home screen
- `/login` - Login screen
- `/register` - Registration screen
- `/splash` - Splash screen
- `/pending` - Pending approval screen
- `/rejected` - Rejected screen

### Premium Routes
- Home (Dashboard)
- Activities (Timeline)
- Add Entry (Activity/Coding/Academic)
- Profile
- Coding (Coding problems)

## Testing

### Manual Testing
- App tested on Android emulator
- All premium screens verified
- Navigation working correctly
- No overflow issues detected

### Known Issues
- None currently

## Contact

**Department**: CSIT Department, AITR
**Project**: MyCSIT - Student Productivity Platform
**Version**: 2.0 (Premium UI)

---

Last Updated: May 2026
