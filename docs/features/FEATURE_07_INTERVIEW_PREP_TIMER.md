# Feature 7: Interview Prep Timer

## Overview

A focused 15-minute mock interview session triggered after each build weekend. The app presents a rotating prompt ("Explain what you built this week in 2 minutes") and runs a countdown timer. No external dependencies — entirely self-contained. This directly fulfills rule #5 from the plan: "15 min mock interviews with AI after each weekend."

---

## User Stories

1. **As Mohamed**, on Saturday evening after completing my tasks, the app nudges me to do a 15-min mock interview.
2. **As Mohamed**, I see a prompt to answer out loud, with a countdown timer so I know how much time I have.
3. **As Mohamed**, I can skip prompts I don't want, add time, or end the session early.
4. **As Mohamed**, the session has multiple prompt rounds (2-3 min each) that cover different angles of what I built.
5. **As Mohamed**, I can rate how well I explained each prompt (easy self-assessment).

---

## Session Structure

Default: **15 minutes**, split into prompt rounds.

### Round Types (3 per session, 5 min each)

| Round | Prompt Template | Purpose |
|-------|----------------|---------|
| 1 — The Pitch | "Explain what you built this week in 2 minutes, like you're in an interview." | High-level framing |
| 2 — Deep Dive | "Walk me through one technical decision you made. Why did you choose X over Y?" | Technical depth |
| 3 — Failure | "What broke? What would you do differently?" | Self-awareness |

All prompts are week-aware using `weekPlan.output` and `weekPlan.phase` for context injection.

### Example Prompts (Week 1: Containers)

```
Round 1: "Explain your Dockerized Flask API to someone who's never used containers.
          What problem does Docker solve? Why does it matter for cloud work?"

Round 2: "Walk me through your Dockerfile. What's the difference between CMD and ENTRYPOINT?
          Why did you choose the base image you did?"

Round 3: "What didn't work? What error did you hit and how did you debug it?
          What would you build differently next time?"
```

### Generic Prompts (fallback, any week)

```
"Explain what you shipped this week to a technical interviewer. Be specific."
"What's the most important architectural decision you made this week? Why?"
"If you had to explain this project on a whiteboard, where would you start?"
"What would a senior engineer critique about your implementation?"
"How does what you built this week connect to what you'll build next week?"
```

---

## Timer Screen Design

```
┌─────────────────────────────────────────┐
│  ← Exit                    Round 2/3   │
│                                         │
│         INTERVIEW PREP                  │
│         Week 4 · AUTOMATION             │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │  Deep Dive                      │   │
│  │                                 │   │
│  │  "Walk me through your GitHub   │   │
│  │   Actions workflow. Why did     │   │
│  │   you use a matrix strategy     │   │
│  │   for your build jobs?"         │   │
│  └─────────────────────────────────┘   │
│                                         │
│              04:32                      │
│         [██████░░░░] 5:00              │
│                                         │
│   [+1 min]  [Skip →]  [Done ✓]        │
│                                         │
│  After your answer:                     │
│  ○ Nailed it   ○ OK   ○ Struggled      │
│                                         │
└─────────────────────────────────────────┘
```

### Timer Behavior
- Counts DOWN from prompt duration
- Visual: large mono countdown + linear progress bar
- At 0: gentle chime (system sound), auto-advance to self-assessment
- Self-assessment: 3 options (Nailed it / OK / Struggled) — logged to behavior repo
- After assessment: 3-second transition to next round
- Final round done → session complete screen

### Session Complete Screen
```
┌─────────────────────────────────────────┐
│                                         │
│     ✓  Interview session done           │
│                                         │
│     3 prompts · 15 minutes              │
│                                         │
│   Nailed it: 1   OK: 1   Struggled: 1  │
│                                         │
│   TIP: The "struggled" one is what      │
│   you should study tonight.             │
│                                         │
│        [Done]    [Do it again]          │
│                                         │
└─────────────────────────────────────────┘
```

---

## Entry Points

1. **Saturday dashboard** — after all tasks done, banner appears: "Tasks complete. Time for your 15-min mock interview. [Start →]"
2. **Plan screen** — "Interview Prep" button at the bottom of the week card (always accessible)
3. **Notification** — Saturday evening notification: "Done building? 15-min mock interview. Explain what you built or you'll forget it." (Notification ID 502)

---

## Prompt Data Structure

```dart
class InterviewPrompt {
  final String roundLabel;    // "The Pitch", "Deep Dive", "Failure"
  final String template;      // may contain {output}, {phase} placeholders
  final int durationSeconds;  // default 300 (5 min)
  final List<int> weekNumbers; // empty = all weeks, [1,2] = week-specific
}
```

Stored as a `const List<InterviewPrompt>` in `lib/data/seed/interview_prompts.dart`. No Hive needed for the prompts themselves.

---

## Self-Assessment Tracking

Log each prompt result to `BehaviorRepository` or a simple Hive box:
```dart
class InterviewResult {
  final int weekNumber;
  final String roundLabel;
  final int rating; // 1=struggled, 2=ok, 3=nailed
  final DateTime completedAt;
}
```

This data can later surface: "You've struggled with 'Deep Dive' 3 weeks in a row."

---

## Files to Create / Modify

| File | Action | Description |
|------|--------|-------------|
| `lib/data/seed/interview_prompts.dart` | CREATE | Const list of `InterviewPrompt` objects, week-aware |
| `lib/screens/interview/interview_screen.dart` | CREATE | Full timer + prompt display screen |
| `lib/screens/interview/interview_complete_screen.dart` | CREATE | Session summary |
| `lib/providers/interview_provider.dart` | CREATE | Session state: current round, time remaining, ratings |
| `lib/screens/dashboard/dashboard_screen.dart` | MODIFY | Show "Start Interview" banner when week is 100% complete |
| `lib/screens/plan/plan_screen.dart` | MODIFY | Add Interview Prep button at bottom of week card |
| `lib/services/notification_service.dart` | MODIFY | Add Saturday evening interview prompt notification (ID 502) |

---

## Implementation Notes

- Timer: use `dart:async Timer.periodic(Duration(seconds: 1), ...)` in a `StateNotifier`. No packages needed.
- Sound: `SystemSound.play(SystemSoundType.click)` at zero, or `HapticFeedback.mediumImpact()` as fallback.
- Prompt interpolation: simple `template.replaceAll('{output}', weekPlan.output)`.
- The notification (ID 502) should only fire when Saturday tasks are >= 50% complete (otherwise premature). Check in the scheduling logic.
- Start simple: fixed 3 rounds × 5 minutes. User can add 1 minute or skip. Don't over-engineer the timer state.
- Screen orientation: force portrait (already app-wide setting).
