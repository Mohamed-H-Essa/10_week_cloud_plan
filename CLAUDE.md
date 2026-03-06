# Cloud Study - AI Assistant Guide

## What This App Is

A Flutter iOS app that tracks a **10-week cloud engineering study plan**. The user (Mohamed) lives in Egypt where the work week is Sun-Thu. **Friday and Saturday are his study/build days** (the weekend). The app helps him stay on track with task checklists, progress tracking, notifications, and iOS widgets with motivational messages.

## Critical Domain Context

- **Friday = Build day** (scaffold, code, learn hands-on)
- **Saturday = Deploy day** (deploy, test, break things)
- **Sun-Thu evenings = SAA-C03 study nights** (25 min/night, AWS cert prep)
- **Week starts on Sunday** (Middle East locale)
- **Friday & Saturday are NOT off days** - they are the primary study days
- The plan covers: Containers -> Infrastructure -> Automation -> Cert Prep -> Capstone -> Launch
- SAA-C03 exam target: end of week 6

## Architecture

### State Management: Riverpod 2.x (manual, no code-gen)
- `StateNotifierProvider` for mutable state (settings, plans, completed tasks)
- `Provider` / `Provider.family` for derived/computed values
- Repository providers throw `UnimplementedError` and are overridden in `main.dart` via `ProviderScope`

### Persistence: Hive
- 5 Hive models with **manually-written TypeAdapters** (in `.g.dart` files - these are NOT generated)
- TypeIds: WeekPlan=0, TaskItem=1, ProgressEntry=2, AppSettings=3, Reflection=4
- Boxes: `week_plans`, `progress`, `settings`, `reflections`
- Repositories wrap Hive boxes and are initialized in `main.dart` before `runApp`

### iOS Native: WidgetKit + MethodChannel
- Flutter sends JSON data via `MethodChannel('com.cloudstudy/widgets')` to native side
- `AppDelegate.swift` receives data, writes to `UserDefaults(suiteName: "group.com.cloudstudy.widgets")`
- SwiftUI widgets read from shared UserDefaults
- Widget extension at `ios/CloudStudyWidget/CloudStudyWidget.swift`
- App Group: `group.com.cloudstudy.widgets`

## Project Structure

```
lib/
  main.dart                    # Entry point, Hive init, repo init, seed, notification restore
  app/
    app.dart                   # MaterialApp, AppShell with PageView + AnimatedNavBar (3 tabs)
    theme.dart                 # Material 3 themes, Google Fonts (JetBrains Mono headings, IBM Plex Sans body)
  data/
    models/                    # Hive models + manual TypeAdapters (.g.dart files)
      week_plan.dart           # 15 fields: weekNumber, phase, title, tasks, etc.
      task_item.dart           # id (uuid), text, day ("friday"/"saturday"), isCustom, sortOrder
      progress_entry.dart      # taskId, weekNumber, completedAt
      app_settings.dart        # Notification toggles/times, planStartDate, darkMode, pomodoro
      reflection.dart          # weekNumber, wentWell, toImprove, createdAt
    seed/
      plan_seed.dart           # buildSeedWeeks() - all 10 weeks translated from original JSX
    repositories/              # Thin wrappers around Hive boxes
      study_plan_repository.dart
      progress_repository.dart
      settings_repository.dart
      reflection_repository.dart
  providers/
    repositories_provider.dart  # Provider declarations (overridden in main)
    study_plan_provider.dart    # weekPlansProvider, selectedWeekProvider, currentWeekPlanProvider
    progress_provider.dart      # completedTaskIds, weekProgress, overallProgress, streak, examCountdown
    settings_provider.dart      # Wires notification scheduling to toggle changes
  screens/
    dashboard/dashboard_screen.dart  # Animated hero card, week card, next session, week grid
    plan/plan_screen.dart            # Week selector, task sections, checkboxes, quick note
    edit/edit_week_screen.dart       # ReorderableListView, inline edit, swipe-delete, move-to-week
    settings/settings_screen.dart    # Notification toggles, time pickers, dark mode, start date
    reflection/reflection_sheet.dart # Bottom sheet for weekly reflections
  services/
    notification_service.dart  # flutter_local_notifications, weeknight/weekend scheduling
    widget_service.dart        # MethodChannel bridge to iOS WidgetKit
    export_service.dart        # Markdown export via share_plus
    calendar_service.dart      # Google Calendar placeholder (not implemented)
  shared/
    constants/
      phase_colors.dart        # PhaseColors class, phaseColorMap
      app_constants.dart
    extensions/
      color_ext.dart
      datetime_ext.dart
    widgets/
      animated_nav_bar.dart    # Glassmorphic bottom nav with backdrop blur, haptics, scale animations
      progress_ring.dart       # CustomPainter circular progress
      phase_badge.dart         # Phase-colored badge chip
      mono_text.dart           # JetBrains Mono styled text
ios/
  Runner/AppDelegate.swift     # MethodChannel handler for widget data
  CloudStudyWidget/
    CloudStudyWidget.swift     # WidgetKit: small/medium/large home + lock screen widgets
    Info.plist
```

## Conventions

- **Fonts**: JetBrains Mono for headings/labels/monospace, IBM Plex Sans for body text
- **Color seed**: `#0EA5E9` (sky blue)
- **Phase colors**: Each phase (CONTAINERS, INFRASTRUCTURE, AUTOMATION, CERT, CAPSTONE, LAUNCH) has bg/border/text colors
- **Animations**: Staggered slide-in on dashboard, TweenAnimationBuilder for progress counters, scale bounce on nav items
- **iOS only**: UIDeviceFamily=[1] (iPhone), portrait only
- **No code generation**: Hive adapters are hand-written, Riverpod providers are manual (no annotations)
- **Task IDs**: UUID v4, generated at seed time

## Known Issues / Incomplete Items

- **Widget extension target**: CloudStudyWidget.swift exists but the extension target may not be properly added to the Xcode project (pbxproj). Requires Xcode GUI or manual pbxproj editing.
- **App Group entitlement**: Needs to be configured in Xcode for both main app and widget extension targets.
- **Google Calendar**: `calendar_service.dart` is a placeholder, not implemented.
- **Notification schedule bug (may be fixed)**: Check that `notification_service.dart` schedules build reminders for **Friday & Saturday** (not Sun & Mon). Study nights should be **Sun-Thu**.
- **Widget motivation messages**: Verify `widget_service.dart` `_getMotivation()` treats Fri-Sat as build days (not off days).
- **Dashboard _getNextSession()**: Verify it shows Friday=build, Saturday=deploy (not off days).

## Key Dependencies

- flutter_riverpod ^2.6.1
- hive ^2.2.3 / hive_flutter ^1.1.0
- flutter_local_notifications ^18.0.1
- timezone ^0.10.0
- google_fonts ^6.2.1
- uuid ^4.5.1
- share_plus ^10.1.3
- intl ^0.19.0

## User Preferences

- Prefers impressive, animation-heavy but subtle UI
- Wants toxic/motivational messages (Egyptian context: "stuck in egypt", "your chance to knock a task now")
- Removed timer feature (uses external system)
- Wants iOS widgets: home screen (small/medium/large), lock screen (circular/rectangular/inline)
