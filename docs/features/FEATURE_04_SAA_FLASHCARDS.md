# Feature 4: SAA-C03 Flashcard Notifications & In-App Review

## Overview

Replace the static "tonight's topic" card on the dashboard with an interactive flashcard system. Send push notifications throughout the day with AWS SAA-C03 facts, questions, and cool facts. Users can interact with question notifications to open the app and reveal the answer, and copy questions/answers to paste into other AI apps.

---

## User Stories

1. **As Mohamed**, I receive a push notification with an AWS fact or question at random intervals during the day so I absorb exam knowledge passively.
2. **As Mohamed**, I tap a question notification to open the app where I see the full question and can reveal the answer.
3. **As Mohamed**, I can copy the question or answer text to paste into Claude/ChatGPT for deeper explanation.
4. **As Mohamed**, I can control how often I receive flashcard notifications (manual slider or smart adaptive mode).
5. **As Mohamed**, on weeknights the dashboard shows me a random question from the current week's SAA topic instead of just the topic name.
6. **As Mohamed**, questions I've answered are tracked so I see different ones over time.

---

## Content Design

### Card Types (3 types, weighted)

| Type | Description | Example | Frequency Weight |
|------|-------------|---------|-----------------|
| **Fact** | A single important detail, limit/number, or AWS behavior that's easy to forget | "S3 Object Lock WORM retention: Governance vs Compliance mode — Compliance cannot be overridden even by root." | 50% |
| **Question** | A multiple-choice or short-answer exam-style question | "Which S3 storage class is cheapest for infrequent access with millisecond retrieval?" | 46% |
| **Cool Fact** | An interesting AWS trivia fact, not necessarily exam-critical | "AWS runs on 100+ availability zones across 30+ geographic regions globally." | 4% |

### Content Scale

- **Minimum**: 100 facts + 100 questions + 10 cool facts = 210 total cards
- **Target**: 150 facts + 150 questions + 20 cool facts = 320 cards
- All stored locally in Dart as a const list (no external dependency)
- Cards tagged by SAA domain: `compute`, `storage`, `networking`, `databases`, `security`, `architecture`, `cost`, `monitoring`
- Cards optionally tagged by week number (1-10) for week-relevant surfacing

### Example Fact Cards
```
"RDS Multi-AZ: synchronous replication. RDS Read Replicas: asynchronous replication. Multi-AZ is for HA, Read Replicas are for performance."

"SQS Standard: at-least-once delivery, best-effort ordering. SQS FIFO: exactly-once delivery, strict ordering. Max message size: 256KB."

"Lambda max execution time: 15 minutes. Max memory: 10GB. Deployment package (unzipped): 250MB."

"Route 53 routing policies: Simple, Weighted, Latency, Failover, Geolocation, Geoproximity, Multivalue Answer, IP-based."
```

### Example Question Cards
```
Q: "You need to store session state for a fleet of EC2 instances that auto-scales. The state must survive instance termination. What's the best solution?"
A: "Amazon ElastiCache (Redis or Memcached) or DynamoDB for session state — both are external to the instance lifecycle."

Q: "An S3 bucket has versioning enabled. A user deletes an object. What happens?"
A: "A delete marker is inserted. The object is not actually deleted. To permanently delete, you must delete the specific version."
```

---

## Notification System

### Notification Types

#### Type A: Fact Notification (no action needed)
```
Title: "SAA Fact 🧠"
Body:  "RDS Multi-AZ uses synchronous replication. Read Replicas use async. Don't mix these up on the exam."
```
- Tap to open app → shows the fact card in full
- No special action button

#### Type B: Question Notification (interactive)
```
Title: "SAA Question ❓"
Body:  "Which service provides a managed message queue with exactly-once delivery?"
Action buttons: [Open Answer] [Dismiss]
```
- Tap notification → opens app to flashcard screen showing full question + [Reveal Answer] button
- [Open Answer] action → deep links directly to the answer view

#### Type C: Cool Fact Notification (4% chance)
```
Title: "AWS Fact 💡"
Body:  "AWS has more than 200 fully featured services. The SAA-C03 tests about 25 of them deeply."
```

### Notification IDs
- Range: 300–499 (leaves room; weeknight=100-107, weekend=200-207)
- Schedule individually with `flutter_local_notifications`

### Frequency Control

#### Manual Mode (user-set slider)
- Slider in Settings: 1–8 notifications per day
- Default: 3/day
- Distributed across waking hours (8am–10pm) with random jitter

#### Smart Mode (adaptive)
- Starts at 3/day
- Increases by 1/day if user has opened flashcard notifications in the last 3 days (up to max 8)
- Decreases by 1/day if user has not opened any in 3+ days (floor at 1)
- Resets cadence on exam week (week 6-7): forces max 6/day
- Smart mode piggybacks on existing `BehaviorRepository`

#### Setting in Settings Screen
- New toggle: "Flashcard Notifications" (on/off)
- When on: show `[Smart] [Manual: ____/day]` segmented control
- Manual mode shows a `Slider(min: 1, max: 8)`

---

## In-App Experience

### Dashboard Integration (weeknights only)

Replace the "Tonight's SAA-C03 Session" static card with:

```
┌─────────────────────────────────────┐
│ 📚 Tonight's Question               │
│ ─────────────────────────────────── │
│ Which Route 53 routing policy uses  │
│ health checks + failover?           │
│                                     │
│ [Reveal Answer]    [Skip →]         │
│                                     │
│ 3/150 seen this week                │
└─────────────────────────────────────┘
```

- Shows a random unseen question from current week's SAA domain
- "Reveal Answer" expands card with animated slide-down
- "Skip →" marks as seen and loads next
- Progress indicator: "X/Y seen this week"

### Flashcard Screen (new route)

Accessed from notification tap or dashboard:
- Full-screen card with question
- [Reveal Answer] button → slides answer in
- Below answer: [Copy Question] [Copy Answer] buttons (copies to clipboard via `Clipboard.setData`)
- [Got it ✓] [Still learning ↩] — marks card as mastered or returns it to rotation
- Swipe left/right to navigate

### Card State Tracking

Stored in Hive (new model `FlashcardEntry`):
```
typeId: 5
fields:
  - cardId: String (index into const list)
  - seenAt: DateTime
  - mastered: bool
  - openedFromNotification: bool (for smart frequency tracking)
```

---

## Files to Create / Modify

| File | Action | Description |
|------|--------|-------------|
| `lib/data/seed/saa_flashcards.dart` | CREATE | Const list of 300+ `SaaCard` objects |
| `lib/data/models/flashcard_entry.dart` | CREATE | Hive model typeId=5 |
| `lib/data/models/flashcard_entry.g.dart` | CREATE | Manual TypeAdapter |
| `lib/data/repositories/flashcard_repository.dart` | CREATE | Hive box wrapper |
| `lib/providers/flashcard_provider.dart` | CREATE | Providers for seen cards, current card, mastery |
| `lib/screens/flashcard/flashcard_screen.dart` | CREATE | Full-screen flashcard viewer |
| `lib/shared/widgets/flashcard_card.dart` | CREATE | Reusable animated card widget |
| `lib/services/flashcard_notification_service.dart` | CREATE | Schedules flashcard notifications, handles frequency |
| `lib/screens/dashboard/dashboard_screen.dart` | MODIFY | Replace static SAA card with interactive flashcard |
| `lib/screens/settings/settings_screen.dart` | MODIFY | Add flashcard frequency controls |
| `lib/data/models/app_settings.dart` | MODIFY | Add `flashcardNotificationsEnabled`, `flashcardPerDay`, `flashcardSmartMode` fields |
| `lib/data/models/app_settings.g.dart` | MODIFY | Update TypeAdapter for new fields |
| `lib/main.dart` | MODIFY | Init flashcard repo, schedule flashcard notifications on startup |

---

## Implementation Notes

- The `saa_flashcards.dart` seed file is the bulk of the work (content writing). Split across sessions if needed.
- Notification scheduling: use `zonedSchedule` for each individual notification with calculated fire times. Re-schedule daily on app open.
- Deep link from notification: use `onDidReceiveNotificationResponse` in `NotificationService` → navigate to `FlashcardScreen` with `cardId` payload.
- `SaaCard` is a plain Dart class (not Hive) — only interaction history is persisted.
- Do NOT use external packages for flashcard logic. Keep it all local.
