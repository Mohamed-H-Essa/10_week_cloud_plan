# Known Issues & Pending Work

## Bugs to Verify/Fix

### Schedule Direction (FIXED)
~~Multiple files may still have the wrong day mapping.~~ **Fixed.** All files now correctly treat Friday=build day, Saturday=deploy day, Sun-Thu=study nights.
- Dashboard uses `todayDayTypeProvider` for day-aware display
- Motivation logic extracted to `motivation_service.dart`, used consistently
- Plan screen label corrected to "Weeknight Study (Sun-Thu)"
- Widget service generates day-specific payloads (`dayType`, `todayTasks`)

### Widget Extension Not Linked
- `ios/CloudStudyWidget/` files exist but the extension target may not be added to the Xcode project
- Requires opening in Xcode: File > New > Target > Widget Extension, then replacing generated code
- App Group entitlement must be configured for both Runner and widget extension targets
- Provisioning profiles need the App Group capability

### Xcode Project State
- `flutter create --platforms ios .` was run to fix a corrupted pbxproj
- This may have overwritten custom `Info.plist` settings (UIDeviceFamily, portrait-only, background modes)
- Verify `ios/Runner/AppDelegate.swift` still has the MethodChannel handler (it should based on current state)

## Incomplete Features

### Google Calendar Integration
- `calendar_service.dart` is a placeholder
- Dependencies exist in pubspec.yaml (googleapis, google_sign_in)
- Never implemented

### Dynamic Island
- User requested Dynamic Island support
- Not implemented - would need Live Activities framework

## UI Polish Requests
- User wants "impressive, animation-heavy but subtle" UI throughout
- Dashboard overhauled: mission header, quick stats row, interactive task checklist, motivation card, expandable week grid
- Navbar has glassmorphism + scale bounce
- More animation could be added to Plan screen

## Settings Fixes Applied
- `AppSettings.copyWith()` replaces brittle 14-field manual constructor in settings_provider
- Time validation: hour clamped to 0-23, minute to 0-59
- Smart notification toggle: shows explanatory card + disabled simple toggles with "Managed automatically"
- Behavior recording: always records app opens and task completions, only reschedules when smart mode is on
