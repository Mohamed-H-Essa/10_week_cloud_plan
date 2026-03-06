# Quick Wins: Small High-Impact Improvements

These are individually small changes that each take under a few hours to implement but meaningfully improve the experience. Each is independent — they can be done in any order or batched.

---

## QW-1: Haptic Feedback on Task Completion

**Impact**: Makes checking off tasks feel satisfying and physical.

### What to implement

Add `HapticFeedback.lightImpact()` when a task is toggled to completed (not on un-complete).

**File**: `lib/providers/progress_provider.dart` — in `CompletedTaskIdsNotifier.toggle()`:
```dart
import 'package:flutter/services.dart';

Future<void> toggle(String taskId, int weekNumber) async {
  final wasCompleted = state.contains(taskId);
  await _ref.read(progressRepoProvider).toggleTask(taskId, weekNumber);
  _load();
  if (!wasCompleted) {
    HapticFeedback.lightImpact(); // ← add this
  }
  _updateWidgets();
  _recordBehavior();
}
```

Also add `HapticFeedback.mediumImpact()` when an entire day's tasks reach 100% (all Friday or all Saturday tasks done).

**No new files. No new dependencies.**

---

## QW-2: Task Completion Sound

**Impact**: Audio + haptic together make completion feel rewarding.

### What to implement

Play a short system sound when all of today's tasks are completed (the "all done" moment).

```dart
import 'package:flutter/services.dart';

// When todayDone == todayTotal and todayTotal > 0:
SystemSound.play(SystemSoundType.click);
```

For a richer sound: use `audioplayers: ^6.0.0` package with a bundled short `.mp3` success chime (add to `assets/sounds/task_done.mp3`).

**Files**:
- `lib/providers/progress_provider.dart` — check completion after toggle
- `pubspec.yaml` — add `audioplayers` if going beyond system sounds
- `assets/sounds/` — add sound file if using audioplayers

**Start with `SystemSound` (zero dependencies), upgrade to audioplayers if it feels weak.**

---

## QW-3: "What I Built" Quick Log

**Impact**: Captures what was actually shipped on Saturday — feeds LinkedIn post, interview prep, and personal record.

### What to implement

On the Saturday dashboard (when `dayType == DayType.deploySaturday`), show a quick-entry field below the task checklist:

```
┌──────────────────────────────────────┐
│ 📝 What did you actually ship today? │
│ ┌────────────────────────────────┐   │
│ │ Deployed containerized Flask   │   │
│ │ API to ECS. Broke it. Fixed it.│   │
│ └────────────────────────────────┘   │
│                    [Save]            │
└──────────────────────────────────────┘
```

- Persisted in `WeekPlan.quickNote` (already exists) keyed as `"built: {text}"` prefix, OR add a dedicated `builtThisWeek: String` field to `WeekPlan`
- Pre-populates with existing quickNote if present
- On Saturday celebration or LinkedIn share: this text is shown alongside the LinkedIn template

**Simplest approach**: reuse the existing `QuickNoteField` widget from `plan_screen.dart`, surface it on the dashboard on Saturdays with a different label. Zero new infrastructure needed.

**Files**:
- `lib/screens/dashboard/dashboard_screen.dart` — show QuickNoteField on Saturdays below task checklist
- `lib/data/models/week_plan.dart` — optionally add `builtThisWeek: String` field (or reuse `quickNote`)

---

## QW-4: Exam Countdown Urgency Mode

**Impact**: Creates visual urgency as the exam approaches, keeping the pressure on.

### What to implement

When `examDaysLeft < 14`, the exam chip in the Quick Stats Row changes behavior:

**Visual changes**:
- Background: `Colors.red.shade700` (dark red, not just shade400)
- Text: white bold
- Animated pulse: scale oscillates between 1.0 and 1.06 using `AnimationController` with `Curves.easeInOut` repeat

**When `examDaysLeft < 7`**:
- Add a persistent banner at the top of the dashboard: "7 days to exam. Are you ready?"
- Banner color: red gradient
- Shows the daily SAA question count and a link to flashcard review

**When `examDaysLeft <= 0`**:
- Replace exam chip with "EXAM WEEK" badge
- Dashboard mission header overrides to "CERT MODE" regardless of day type

**Files**:
- `lib/screens/dashboard/dashboard_screen.dart` — modify `_QuickStatsRow`, add urgency banner
- No new files, no new providers (uses existing `examCountdownProvider`)

---

## QW-5: Lock Screen Widget (Xcode Wiring)

**Impact**: The widget code is already written (Feature 4 of the last session). This makes it actually appear on users' lock screens.

### What to implement (Xcode-side, not Flutter)

This is a configuration task, not a code task. Steps:

1. Open `ios/Runner.xcworkspace` in Xcode
2. File → New → Target → Widget Extension
   - Product Name: `CloudStudyWidget`
   - Include Configuration Intent: No
   - Activate scheme: Yes
3. Replace the generated Swift file with the existing `ios/CloudStudyWidget/CloudStudyWidget.swift`
4. Add App Group capability to both Runner and CloudStudyWidget targets:
   - Target → Signing & Capabilities → + App Groups → `group.com.cloudstudy.widgets`
5. Ensure `Info.plist` in widget extension has correct bundle ID: `com.example.cloudStudy.CloudStudyWidget`
6. Build and test on device

**Document the exact Xcode steps in `docs/XCODE_WIDGET_SETUP.md`** so this can be reproduced.

**Files**:
- `ios/CloudStudyWidget/CloudStudyWidget.swift` — already exists and updated
- `ios/Runner.xcworkspace` — modified via Xcode GUI
- `docs/XCODE_WIDGET_SETUP.md` — CREATE with step-by-step guide

---

## Implementation Order Recommendation

| Priority | Feature | Effort | Dependency |
|----------|---------|--------|------------|
| 1 | QW-1: Haptic feedback | 15 min | None |
| 2 | QW-4: Exam urgency mode | 1 hr | None |
| 3 | QW-3: "What I built" log | 1 hr | None |
| 4 | QW-2: Task completion sound | 1-2 hr | None |
| 5 | QW-5: Lock screen widget wiring | 2-3 hr | Xcode access |
