# Cloud Study — Feature TODO

Each major feature gets its own chat session to keep context clean and quality high.
After implementing a feature, do a full context reset before starting the next one.

---

## How to Use This File

1. Pick a feature block below
2. Start a fresh Claude Code session
3. Say: "Implement [FEATURE NAME]. The full spec is in `docs/features/[FILE].md`"
4. After it's done and tested → check the box ✅ → reset chat

---

## Quick Wins (can batch in one session)

These are small and independent. Do them together before the major features.
Spec: `docs/features/FEATURE_QUICK_WINS.md`

- [ ] **QW-1** — Haptic feedback on task completion
  - File: `lib/providers/progress_provider.dart`
  - `HapticFeedback.lightImpact()` on toggle to completed, `mediumImpact()` when all day tasks done

- [ ] **QW-2** — Task completion sound
  - Files: `lib/providers/progress_provider.dart`, optionally `pubspec.yaml` + `assets/sounds/`
  - `SystemSound.play(SystemSoundType.click)` when all today's tasks complete. Upgrade to audioplayers if needed.

- [ ] **QW-3** — "What I built" quick log on Saturday dashboard
  - File: `lib/screens/dashboard/dashboard_screen.dart`
  - Surface existing `QuickNoteField` on Saturdays with "What did you ship?" label

- [ ] **QW-4** — Exam countdown urgency mode
  - File: `lib/screens/dashboard/dashboard_screen.dart`
  - Pulse animation + red styling when `examDaysLeft < 14`, banner when `< 7`, CERT MODE override when `<= 0`

- [ ] **QW-5** — Lock screen widget Xcode wiring
  - Not a code task — Xcode configuration (App Group, widget extension target)
  - Document steps in `docs/XCODE_WIDGET_SETUP.md`

---

## Feature 4: SAA-C03 Flashcard Notifications & In-App Review

**Spec**: `docs/features/FEATURE_04_SAA_FLASHCARDS.md`
**Complexity**: Large (content-heavy + new Hive model + notification system)
**Recommended session split**:
  - Session A: Data layer (flashcard content seed, Hive model, repository, providers)
  - Session B: In-app UI (flashcard screen, dashboard integration, shared widget)
  - Session C: Notifications (scheduling, frequency control, settings, deep link)

### Subtasks

- [ ] **F4-A1** — Create `SaaCard` class and write 100+ fact cards in `lib/data/seed/saa_flashcards.dart`
- [ ] **F4-A2** — Write 100+ question cards (with answers) and 10+ cool facts
- [ ] **F4-A3** — Create `FlashcardEntry` Hive model (typeId=5) + manual TypeAdapter in `.g.dart`
- [ ] **F4-A4** — Create `FlashcardRepository` (Hive box wrapper for interaction history)
- [ ] **F4-A5** — Create `flashcard_provider.dart` (seen cards, current card, mastery state)
- [ ] **F4-B1** — Create `lib/shared/widgets/flashcard_card.dart` (animated reveal widget)
- [ ] **F4-B2** — Create `lib/screens/flashcard/flashcard_screen.dart` (full-screen viewer with copy buttons)
- [ ] **F4-B3** — Modify dashboard: replace static SAA card with interactive flashcard on weeknights
- [ ] **F4-C1** — Create `lib/services/flashcard_notification_service.dart`
  - Schedules fact/question/cool-fact notifications (IDs 300–499)
  - Manual mode: distribute N notifications across 8am–10pm with jitter
  - Smart mode: adjust frequency based on open rate (reads from behavior repo)
- [ ] **F4-C2** — Handle notification deep link → navigate to `FlashcardScreen` with card ID
- [ ] **F4-C3** — Add settings fields to `AppSettings`: `flashcardNotificationsEnabled`, `flashcardPerDay`, `flashcardSmartMode`
- [ ] **F4-C4** — Add flashcard frequency controls to Settings screen (toggle + slider + smart/manual segmented control)
- [ ] **F4-C5** — Wire up in `main.dart`: init flashcard repo, schedule flashcard notifications on startup

---

## Feature 5: Terraform Destroy Reminder

**Spec**: `docs/features/FEATURE_05_TERRAFORM_DESTROY_REMINDER.md`
**Complexity**: Small (1 session)

- [ ] **F5-1** — Add `scheduleTerraformDestroy()` and `cancelTerraformDestroy()` to `notification_service.dart`
  - Primary: Saturday 9 PM (ID 500), rotating message variants
  - Follow-up: Saturday 11 PM (ID 501), only if unacknowledged
- [ ] **F5-2** — Add `terraformDestroyReminderEnabled: bool` and `terraformDestroyAcknowledgedWeek: int?` to `AppSettings`
  - Update TypeAdapter in `.g.dart`
- [ ] **F5-3** — Add `setTerraformDestroyReminder(bool)` to `settings_provider.dart`
- [ ] **F5-4** — Add toggle to Settings screen under NOTIFICATIONS
- [ ] **F5-5** — Add Saturday evening acknowledgment banner to dashboard
  - Shows after 9 PM on Saturday if current week not acknowledged
  - "Yes, done ✓" → cancel follow-up notification + persist acknowledgment
- [ ] **F5-6** — Wire up in `main.dart`: schedule on startup if enabled (default: enabled)

---

## Feature 6: Week Completion Celebration

**Spec**: `docs/features/FEATURE_06_WEEK_COMPLETION_CELEBRATION.md`
**Complexity**: Medium (1-2 sessions)

- [ ] **F6-1** — Create `lib/providers/celebration_provider.dart`
  - `StateProvider<int?>` — holds weekNumber to celebrate (null = no celebration pending)
- [ ] **F6-2** — Modify `CompletedTaskIdsNotifier.toggle()` in `progress_provider.dart`
  - After `_load()`, check if any uncelebrated week just hit 100%
  - If yes, set `celebrationProvider` to that weekNumber
- [ ] **F6-3** — Add `celebratedWeeks: List<int>` to `AppSettings`
  - Update TypeAdapter in `.g.dart`
- [ ] **F6-4** — Create confetti particle system
  - Option A: Add `confetti: ^0.7.0` to `pubspec.yaml`
  - Option B: Custom `CustomPainter` particle system (no new dependency)
- [ ] **F6-5** — Create `lib/screens/celebration/week_celebration_screen.dart`
  - Full-screen overlay with: confetti, phase badge, stats row, LinkedIn post card
  - Animation sequence: bg fade → badge bounce → title slide → stats fade → linkedin slide
  - [Copy LinkedIn Post] → `Clipboard.setData` + haptic + "Copied!" snackbar
  - [Continue →] → dismisses overlay + resets celebration provider to null
- [ ] **F6-6** — Modify `lib/app/app.dart`
  - `ref.listen` on `celebrationProvider` → `showGeneralDialog` with celebration screen
  - Ensure `barrierDismissible: false`

---

## Feature 7: Interview Prep Timer

**Spec**: `docs/features/FEATURE_07_INTERVIEW_PREP_TIMER.md`
**Complexity**: Medium (1 session)

- [ ] **F7-1** — Create `lib/data/seed/interview_prompts.dart`
  - `InterviewPrompt` class with `roundLabel`, `template`, `durationSeconds`, `weekNumbers`
  - Write 30+ prompts: week-specific (W1-W10) + generic fallbacks for all 3 round types
- [ ] **F7-2** — Create `lib/providers/interview_provider.dart`
  - `InterviewSessionNotifier extends StateNotifier<InterviewSessionState>`
  - State: `currentRound`, `secondsRemaining`, `ratings`, `isComplete`, `prompts`
  - Uses `Timer.periodic` for countdown (no packages)
- [ ] **F7-3** — Create `lib/screens/interview/interview_screen.dart`
  - Round display: round label, prompt card, large countdown, progress bar
  - Controls: [+1 min] [Skip →] [Done ✓]
  - Self-assessment row: [Nailed it] [OK] [Struggled]
  - Auto-advance to assessment at 0, then 3s transition to next round
- [ ] **F7-4** — Create `lib/screens/interview/interview_complete_screen.dart`
  - Summary: prompts done, ratings breakdown
  - Tip: "You struggled with X — study that tonight"
  - [Done] [Do it again]
- [ ] **F7-5** — Add Saturday dashboard banner: show when week tasks >= 100% complete
  - "Tasks done. Time for mock interview. [Start →]"
  - Routes to `InterviewScreen` with current week's prompts
- [ ] **F7-6** — Add Interview Prep button to Plan screen week card footer
- [ ] **F7-7** — Add Saturday evening notification (ID 502) when tasks >= 50% complete
  - "Done building? 15-min mock interview. Explain what you built or you'll forget it."

---

## Completed Features (from previous sessions)

- [x] Dashboard rewrite (mission header, today's tasks, SAA card, motivation, expandable week grid)
- [x] `today_provider.dart` foundation (DayType, TimeContext, todayTasks, todaySaaTopic)
- [x] `motivation_service.dart` extracted (shared by dashboard + widgets)
- [x] Shared `TaskChecklist` widget
- [x] iOS widget expansion (NextTask, Streak, Motivation, TodayLockRect widgets)
- [x] Widget payload expansion (streak, dayType, todayTasks, nextTask, saaTopic)
- [x] Settings fixes (copyWith, time validation, smart notification UX, behavior recording)
- [x] Plan screen label fix (Sun-Thu weeknights)
