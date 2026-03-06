# Feature 6: Week Completion Celebration

## Overview

When a week's `weekProgress` reaches 1.0 (all Friday + Saturday tasks checked), the app shows a full-screen celebration moment with confetti, the phase badge, week stats, and the LinkedIn post template pre-filled for copying. Right now, completing a week is completely invisible — this makes it feel like an achievement.

---

## User Stories

1. **As Mohamed**, when I check the last remaining task of a week, I see a satisfying celebration screen.
2. **As Mohamed**, the celebration shows my stats for the week (tasks done, days taken, streak contribution).
3. **As Mohamed**, I see the pre-written LinkedIn post for this week and can copy it to my clipboard in one tap.
4. **As Mohamed**, I can dismiss the celebration and return to the dashboard.
5. **As Mohamed**, the celebration never shows twice for the same week (state is persisted).

---

## Trigger Logic

The celebration triggers when:
- `weekProgress` transitions to exactly `1.0` (all tasks done)
- The week has not been celebrated before (stored in Hive)
- The user is on the dashboard or plan screen

Specifically: in `CompletedTaskIdsNotifier.toggle()`, after `_load()`, check if any week just hit 100% completion and hasn't been celebrated → emit a one-shot celebration event.

---

## Celebration Screen Design

Full-screen overlay (modal route, not a push route — so back stack is preserved):

```
┌─────────────────────────────────────────┐
│                                         │
│           🎉  WEEK COMPLETE             │
│                                         │
│         [PHASE BADGE: CONTAINERS]       │
│                                         │
│      WEEK 1: Docker + Your First API    │
│                                         │
│   ✓ 9 tasks    🔥 5-day streak          │
│   ✓ Fri + Sat done                      │
│                                         │
│  ─────────────────────────────────────  │
│  LINKEDIN POST                          │
│  "Week 1 done. Containerized my        │
│   first Flask API with Docker..."       │
│                                         │
│        [Copy LinkedIn Post]             │
│                                         │
│   [Share as Image]    [Continue →]      │
│                                         │
└─────────────────────────────────────────┘
```

### Confetti
- Use package `confetti: ^0.7.0` (already common in Flutter ecosystem, or implement a simple particle system with CustomPainter to avoid dependencies)
- Phase-colored confetti particles
- Fires for 3 seconds, then settles

### Animation Sequence
1. Background fades in (200ms)
2. Badge scales in with spring bounce (400ms)
3. Title slides up (300ms, 200ms delay)
4. Stats row fades in (300ms, 400ms delay)
5. LinkedIn card slides up from bottom (400ms, 500ms delay)
6. Confetti fires simultaneously with step 2

---

## State Persistence

New field in `AppSettings` (simplest approach — avoids new Hive model):
```dart
@HiveField(15)
List<int> celebratedWeeks; // list of weekNumbers already celebrated
```

Or a separate `Set<int>` stored as a `List<int>` in Hive box 'progress' with a fixed key.

Check before showing: `if (celebratedWeeks.contains(weekNumber)) return;`
After showing: `celebratedWeeks.add(weekNumber)` and persist.

---

## LinkedIn Post Integration

Each `WeekPlan` already has:
- `linkedinPost` — the post text
- `linkedinAngle` — context/tip for the post

On the celebration screen:
- Show `linkedinPost` in a styled card
- [Copy LinkedIn Post] button → `Clipboard.setData(ClipboardData(text: plan.linkedinPost))` + haptic feedback + "Copied!" snackbar
- [Share as Image] — optional Phase 2 (render week card to image via `RepaintBoundary`)

---

## Week Stats to Display

| Stat | Source |
|------|--------|
| Tasks completed | `weekTotal` (from weekProgress providers) |
| Streak | `streakProvider` |
| Phase | `weekPlan.phase` |
| Week number | `weekPlan.weekNumber` |

---

## Files to Create / Modify

| File | Action | Description |
|------|--------|-------------|
| `lib/screens/celebration/week_celebration_screen.dart` | CREATE | Full-screen celebration overlay |
| `lib/providers/progress_provider.dart` | MODIFY | Emit celebration trigger when week hits 100% |
| `lib/providers/celebration_provider.dart` | CREATE | `celebrationTriggerProvider` — one-shot stream or state |
| `lib/data/models/app_settings.dart` | MODIFY | Add `celebratedWeeks: List<int>` |
| `lib/data/models/app_settings.g.dart` | MODIFY | Update TypeAdapter |
| `lib/app/app.dart` | MODIFY | Listen to `celebrationTriggerProvider` and show overlay |

---

## Implementation Notes

- The celebration should be an overlay/dialog (use `showGeneralDialog` with `barrierDismissible: false`) so it doesn't break navigation state.
- The trigger from `progress_provider.dart` must be a one-shot event, not a persistent state. Use `StateProvider<int?>` (week number that needs celebration, null when none) — set it, show the overlay, reset to null.
- Listen in `app.dart` using `ref.listen` on the celebration provider → `showGeneralDialog`.
- Confetti: implement a simple `CustomPainter` particle system rather than adding a package. ~60 particles, gravity, phase color variants. Or add `confetti: ^0.7.0` to `pubspec.yaml` if speed matters.
- "Share as Image" is optional and can be a follow-up task.
