# Feature 5: Terraform Destroy Reminder

## Overview

A contextual, time-specific Saturday evening notification reminding Mohamed to run `terraform destroy` before Sunday. The rules of the plan explicitly state: "terraform destroy every Saturday night. Rebuild next Friday in minutes. No surprise bills." This feature makes that rule automatic and impossible to ignore.

---

## User Stories

1. **As Mohamed**, I receive a notification at 9 PM every Saturday reminding me to run `terraform destroy`.
2. **As Mohamed**, the notification contains direct, blunt language consistent with the app's toxic motivation style.
3. **As Mohamed**, I can tap the notification to open the app and mark "Destroy done" — stopping the follow-up nag.
4. **As Mohamed**, if I don't acknowledge by 11 PM, I get a follow-up "last call" notification.
5. **As Mohamed**, I can configure or disable this reminder from Settings.

---

## Notification Flow

### Primary Notification (9:00 PM Saturday)
```
Title: "terraform destroy"
Body:  "Saturday is ending. Have you destroyed your infra? No? AWS bill incoming. Run it now."
Action: [Done ✓] [Remind in 1hr]
```

### Follow-up Notification (11:00 PM Saturday, only if not acknowledged)
```
Title: "Last call. terraform destroy."
Body:  "It's 11 PM. You're about to leave infra running overnight. That's money. Destroy it."
Action: [Done ✓]
```

### Notification IDs
- Primary: ID 500
- Follow-up: ID 501

---

## In-App Experience

### Confirmation Banner

When the user opens the app on Saturday after the notification fires (and hasn't acknowledged), show a dismissible banner at the top of the dashboard:

```
┌───────────────────────────────────────┐
│ ⚠️  terraform destroy                 │
│  Did you tear down your infra yet?    │
│  [Yes, done ✓]           [Dismiss]   │
└───────────────────────────────────────┘
```

- Tapping "Yes, done ✓" cancels the follow-up notification (ID 501) and persists acknowledgment in Hive
- Banner only shows on Saturdays after 9 PM

### Settings Toggle

Under the existing NOTIFICATIONS section in Settings:

```
[🔥] Terraform Destroy Reminder
     "Sat 9 PM — destroy your infra before Sunday"
     [Toggle: on/off]
```

---

## State Persistence

Track acknowledgment to avoid re-showing after dismiss:

- Key in `AppSettings` (or a simple Hive box entry): `terraformDestroyAcknowledgedWeek: int?`
- Stores the week number of the last acknowledgment
- If current week matches stored week → don't show banner or follow-up

---

## Scheduling Logic

On app startup (main.dart), and whenever the setting is toggled on:

```dart
// Cancel existing
await NotificationService.cancel(500);
await NotificationService.cancel(501);

if (enabled) {
  // Schedule primary: next Saturday 9 PM
  await NotificationService.scheduleTerraformDestroy(
    primaryHour: 21, primaryMinute: 0,   // 9:00 PM
    followUpHour: 23, followUpMinute: 0, // 11:00 PM
  );
}
```

Use `DateTimeComponents.dayOfWeekAndTime` with `DateTime.saturday` for weekly recurrence.

---

## Content Variations (Rotating)

Primary notification rotates through these each week:

```
"Saturday is ending. Have you destroyed your infra? No? AWS bill incoming. Run it now."
"terraform destroy. Not a suggestion. A rule you made for yourself."
"Every undeleted resource = real money. Saturday ends in hours. terraform destroy."
"The plan says destroy every Saturday night. Are you following your own plan?"
"Clock's ticking. terraform destroy before you forget and wake up to a bill."
```

Follow-up:
```
"Still running? 11 PM. Last chance to not pay AWS for nothing."
"Did you seriously forget? terraform destroy. Right now."
```

---

## Files to Create / Modify

| File | Action | Description |
|------|--------|-------------|
| `lib/services/notification_service.dart` | MODIFY | Add `scheduleTerraformDestroy()` and `cancelTerraformDestroy()` methods |
| `lib/data/models/app_settings.dart` | MODIFY | Add `terraformDestroyReminderEnabled: bool`, `terraformDestroyAcknowledgedWeek: int?` |
| `lib/data/models/app_settings.g.dart` | MODIFY | Update TypeAdapter |
| `lib/providers/settings_provider.dart` | MODIFY | Add `setTerraformDestroyReminder(bool)` method |
| `lib/screens/settings/settings_screen.dart` | MODIFY | Add toggle in NOTIFICATIONS section |
| `lib/screens/dashboard/dashboard_screen.dart` | MODIFY | Add Saturday evening acknowledgment banner |
| `lib/main.dart` | MODIFY | Schedule/restore terraform destroy notification on startup |

---

## Implementation Notes

- This is intentionally simple. No new Hive models needed — piggyback on `AppSettings` fields.
- The follow-up notification (ID 501) is scheduled at the same time as the primary but with a 2-hour delay. On acknowledgment, call `NotificationService.cancel(501)`.
- Notification tap action: set a payload `'terraform_destroy'` and handle in `onDidReceiveNotificationResponse` to open the dashboard and show the acknowledgment UI.
- Default: **enabled** (opt-out, not opt-in) — this is a core rule of the plan.
