/// Standalone motivation message generator used by both dashboard and widget service.
String getMotivation(int currentWeek, double progress) {
  final now = DateTime.now();
  final hour = now.hour;
  final weekday = now.weekday;

  // Day-specific messages
  if (weekday == DateTime.friday) {
    if (hour < 10) {
      return "It's Friday. Time to build. No excuses.";
    } else if (hour < 14) {
      return "Build session is NOW. Open the terminal.";
    } else {
      return "Friday's not over. Ship something before midnight.";
    }
  }

  if (weekday == DateTime.saturday) {
    if (hour < 10) {
      return "Saturday deploy day. Break what you built yesterday.";
    } else if (hour < 14) {
      return "Deploy, test, break it. That's the loop.";
    } else {
      return "It's Saturday and you're still not done. Ship it.";
    }
  }

  // Weeknight study (Sun-Thu)
  if (hour < 12) {
    final morningMessages = [
      "Tonight: SAA study. No Netflix. You chose this.",
      "Every skipped night = 1 more week stuck where you are.",
      "25 minutes tonight. That's it. You can do 25 minutes.",
    ];
    return morningMessages[now.day % morningMessages.length];
  }

  if (hour >= 18 && hour < 22) {
    final eveningMessages = [
      "It's study time. Open the course. NOW.",
      "15 minutes counts. Perfection is the enemy.",
      "The people getting hired are studying right now.",
      "Skip tonight and explain to future you why.",
      "Even 1 practice question > 0 practice questions.",
    ];
    return eveningMessages[now.minute % eveningMessages.length];
  }

  if (hour >= 22) {
    return "Late but not too late. Even 15 min counts.";
  }

  // Progress-based
  if (progress == 0) {
    return "Zero progress. The plan won't execute itself.";
  }
  if (progress < 0.2) {
    return "Week $currentWeek of 10. Momentum hasn't kicked in yet. Keep going.";
  }
  if (progress < 0.5) {
    return "${(progress * 100).round()}% done. You're in the thick of it. Don't quit now.";
  }
  if (progress < 0.8) {
    return "Past halfway. The hardest part is behind you.";
  }
  return "Almost there. Finish what you started.";
}
