# Architecture Overview

## App Model & Idea

Cloud Study is a personal study tracker for a 10-week cloud engineering curriculum. The user (based in Egypt) studies on **Fridays and Saturdays** (the local weekend) and does SAA-C03 cert prep on weeknight evenings (Sun-Thu).

### The 10-Week Plan

Each week follows a consistent structure:
- **Friday**: Build session (scaffold APIs, write Terraform, set up CI/CD, etc.)
- **Saturday**: Deploy session (deploy to cloud, test, break things, document)
- **Weeknights (Sun-Thu)**: 25-min SAA-C03 study sessions

The plan progresses through 6 phases:
1. **CONTAINERS** (W1): Docker + first deployable API
2. **INFRASTRUCTURE** (W2-3): Terraform, VPC, ECS, RDS, monitoring
3. **AUTOMATION** (W4-5): CI/CD, GitHub Actions, multi-env, security scanning
4. **CERT** (W6-7): SAA-C03 exam prep + practice exams
5. **CAPSTONE** (W8-9): Full platform build + chaos engineering
6. **LAUNCH** (W10): Portfolio, LinkedIn, job applications

### Motivational System

The app uses "toxic motivation" - blunt, relatable messages designed to push the user to study. Examples:
- "If you didn't do this you'll be stuck in Egypt"
- "It's Friday already - your chance to knock a task now"
- "Even 15 minutes counts. Perfection is the enemy."

These appear in iOS widgets (home screen and lock screen) and are time/day-aware.

## Data Flow

```
┌─────────────────────────────────────────────┐
│                  main.dart                   │
│  Hive init -> Repo init -> Seed -> runApp    │
└────────────────────┬────────────────────────┘
                     │
    ProviderScope (repo overrides)
                     │
         ┌───────────┴───────────┐
         │                       │
    ┌────┴────┐           ┌──────┴──────┐
    │ Screens │           │  Providers   │
    │ (UI)    │──watch──> │ (State)      │
    │         │<──read──  │              │
    └─────────┘           └──────┬──────┘
                                 │
                          ┌──────┴──────┐
                          │ Repositories │
                          │ (Hive boxes) │
                          └─────────────┘
```

### Hive Boxes

| Box Name      | Model          | TypeId | Key Strategy      |
|---------------|----------------|--------|-------------------|
| week_plans    | WeekPlan       | 0      | weekNumber (1-10) |
| progress      | ProgressEntry  | 2      | auto-increment    |
| settings      | AppSettings    | 3      | single key (0)    |
| reflections   | Reflection     | 4      | weekNumber        |

TaskItem (typeId: 1) is stored inline within WeekPlan's fridayTasks/saturdayTasks lists.

### Provider Dependency Graph

```
settingsRepoProvider ──> settingsProvider (StateNotifier<AppSettings>)
                    └──> currentWeekNumberProvider
                    └──> examCountdownProvider

studyPlanRepoProvider ──> weekPlansProvider (StateNotifier<List<WeekPlan>>)
                     └──> selectedWeekProvider (StateProvider<int>)
                     └──> currentWeekPlanProvider (derived)

progressRepoProvider ──> completedTaskIdsProvider (StateNotifier<Set<String>>)
                    └──> weekProgressProvider(weekNumber) (derived)
                    └──> overallProgressProvider (derived)
                    └──> streakProvider (derived)

todayDayTypeProvider ──> todayTasksProvider (derived from weekPlans + completedTaskIds)
                    └──> todayPendingCountProvider (derived)
                    └──> nextUncompletedTaskProvider (derived)
                    └──> todaySaaTopicProvider (derived, Sun-Thu only)
                    └──> todaySaaScheduleProvider (derived, Sun-Thu only)
timeOfDayContextProvider (standalone, based on clock hour)
```

### Today-Aware Provider Layer

`lib/providers/today_provider.dart` provides day-specific state consumed by both the dashboard and widget service:

- **DayType enum**: `buildFriday`, `deploySaturday`, `studyNight` — based on `DateTime.now().weekday`
- **TimeContext enum**: `morning`, `afternoon`, `evening`, `lateNight` — based on hour
- **todayTasksProvider**: Returns Friday or Saturday tasks with completion status, empty on weeknights
- **todaySaaTopicProvider / todaySaaScheduleProvider**: Returns SAA study info on weeknights, null otherwise

### Shared Widgets

`lib/shared/widgets/task_checklist.dart` — Reusable interactive task checklist used by both the dashboard and plan screens. Supports a `compact` mode for dashboard use.

### iOS Widget Data Flow

```
Flutter App
    │
    ├── WidgetService.updateWidgets()
    │   (calculates progress, picks motivation message)
    │
    ├── MethodChannel('com.cloudstudy/widgets')
    │
    ▼
AppDelegate.swift
    │
    ├── Receives JSON via method channel
    ├── Writes to UserDefaults(suiteName: appGroup)
    ├── Calls WidgetCenter.shared.reloadAllTimelines()
    │
    ▼
CloudStudyWidget.swift (WidgetKit Extension)
    │
    ├── TimelineProvider reads UserDefaults
    ├── Renders SwiftUI views for each widget family
    │
    ├── Home Screen: systemSmall, systemMedium, systemLarge
    ├── Home Screen (dedicated): Next Task (small), Streak (small), Motivation (small)
    ├── Lock Screen: accessoryCircular, accessoryRectangular, accessoryInline
    └── Lock Screen: Today's Progress (accessoryRectangular)
```

Widget data payload includes:
- Core stats: `overallProgress`, `totalTasks`, `completedTasks`, `weekProgress`, etc.
- Today-specific: `dayType`, `todayTasks` (list with completion), `nextTask`, `saaTopic`
- Gamification: `streak`
- Context: `motivation` (generated by `motivation_service.dart`)

## Navigation

3-tab PageView with custom glassmorphic AnimatedNavBar:
1. **Home** (Dashboard) - Today's mission header, quick stats, interactive task checklist (or SAA session card on weeknights), motivation quote, current week card
2. **Plan** - Week selector, task checklists, quick notes
3. **Settings** - Notifications, theme, start date, export

Additional screens pushed from Plan:
- **Edit Week** - Reorder/add/delete/move tasks
- **Reflection Sheet** - Weekly retrospective (bottom sheet)
- **About Plan** - Rules, buffer notes, cost summary

## Notification Schedule

Two notification groups:
1. **Weeknight** (IDs 100-107): Study reminders for Sun-Thu evenings
2. **Weekend** (IDs 200-207): Build day reminders for Fri & Sat mornings

Scheduling uses `flutter_local_notifications` with `DateTimeComponents.dayOfWeekAndTime` for weekly recurrence. Permissions are requested on first toggle. Schedules are restored on app startup.

## Theming

- Material 3 with color seed `#0EA5E9`
- Light + Dark mode (system default, user override)
- Google Fonts: JetBrains Mono (headings, labels, monospace UI), IBM Plex Sans (body)
- Phase-specific colors for week cards and badges (see `phase_colors.dart`)
- Glassmorphic elements: backdrop blur on navbar, translucent containers
