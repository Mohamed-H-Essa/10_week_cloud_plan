# Known Issues & Pending Work

## Bugs to Verify/Fix

### Schedule Direction (HIGH PRIORITY)
Multiple files may still have the wrong day mapping from a previous misunderstanding. **Friday and Saturday are BUILD/STUDY days, NOT off days.**

Files to check:
- `lib/services/notification_service.dart` - `scheduleWeekend()` should fire on Fri & Sat (not Sun & Mon)
- `lib/screens/dashboard/dashboard_screen.dart` - `_getNextSession()` should show Fri=build, Sat=deploy
- `lib/services/widget_service.dart` - `_getMotivation()` should treat Fri-Sat as build days
- `ios/CloudStudyWidget/CloudStudyWidget.swift` - motivation messages (if generated there)
- `lib/screens/settings/settings_screen.dart` - labels should say "Fri & Sat" for weekend reminders

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
- Dashboard has staggered animations and glass chips
- Navbar has glassmorphism + scale bounce
- More animation could be added to Plan screen and Settings screen
