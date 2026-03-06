import 'dart:math';

class NotificationMessages {
  static final _rng = Random();

  static const moods = [
    'celebrate',
    'gentle_nudge',
    'streak_warning',
    'comeback',
    'overwhelm_comfort',
    'task_specific',
    'milestone',
    'friday_build',
    'saturday_deploy',
    'weeknight_study',
  ];

  static const _templates = <String, List<Map<String, String>>>{
    'celebrate': [
      {'title': 'Momentum!', 'body': 'You checked off {taskCount} tasks today. More than most people do in a week.'},
      {'title': 'On fire', 'body': '{streak}-day streak. You are literally unstoppable right now.'},
      {'title': 'Look at you go', 'body': '{progress}% through Week {week}. This is what progress looks like.'},
      {'title': 'Beast mode', 'body': 'Another task down. Keep stacking these wins.'},
      {'title': 'No brakes', 'body': "You're outpacing your own plan. That's rare. That's you."},
      {'title': 'Respect', 'body': 'Most people talk about cloud. You actually build. {taskCount} tasks prove it.'},
      {'title': 'W', 'body': "Week {week} is getting demolished. You love to see it."},
      {'title': 'Machine', 'body': '{streak} days straight. The compound effect is real.'},
      {'title': 'Certified grinder', 'body': 'Task done. Exam in {examDays} days. You will be ready.'},
      {'title': 'Locked in', 'body': "You showed up again. That's the whole secret."},
      {'title': 'Built different', 'body': '{phase} phase. {progress}% done. This is your trajectory now.'},
      {'title': 'Chef kiss', 'body': "That task you just finished? Future-you is grateful."},
      {'title': 'Stacking', 'body': 'Every task is a brick. You are building something real.'},
      {'title': 'Unstoppable', 'body': '{taskCount} down today. The plan bows to your discipline.'},
      {'title': 'Legend behavior', 'body': 'Studying while Egypt sleeps. This is how people escape.'},
    ],
    'gentle_nudge': [
      {'title': 'Quick check-in', 'body': "One task. That's all. Pick the easiest one."},
      {'title': 'Still here', 'body': "Your plan is waiting. Just open the app and pick one thing."},
      {'title': 'Small win?', 'body': 'Even 5 minutes of progress beats 0. You know this.'},
      {'title': 'Hey', 'body': "Yesterday was solid. Keep it going today. Just one task."},
      {'title': 'Nudge', 'body': '{pendingTasks} tasks left in Week {week}. Pick the smallest one.'},
      {'title': 'Easy one', 'body': "Start with something simple. Momentum builds from there."},
      {'title': 'Remember why', 'body': 'Cloud engineering. Better salary. Better life. One task closer.'},
      {'title': 'Tiny step', 'body': "You don't need to finish everything. Just start one thing."},
      {'title': 'Check in', 'body': "How's Week {week} going? {pendingTasks} tasks waiting for you."},
      {'title': 'Low pressure', 'body': "No rush. But also... {examDays} days to exam. Just saying."},
      {'title': 'Psst', 'body': 'Your {phase} tasks miss you. Just one. Promise.'},
      {'title': 'Quick one', 'body': "Open the app. Read one task. If it's easy, do it. That's it."},
      {'title': 'Gentle push', 'body': "The plan doesn't judge. It just waits. Ready when you are."},
      {'title': 'Light touch', 'body': '25 minutes tonight? Shorter than scrolling Instagram.'},
      {'title': 'Your move', 'body': 'Week {week} is {progress}% done. A little push and you are ahead.'},
    ],
    'streak_warning': [
      {'title': 'Streak alert', 'body': '{streak}-day streak dies at midnight. One task saves it. ONE.'},
      {'title': 'Don\'t break it', 'body': '{streak} days of consistency on the line. 5 minutes is all it takes.'},
      {'title': 'Midnight deadline', 'body': 'Your {streak}-day streak expires tonight. Is that really how this ends?'},
      {'title': 'Streak at risk', 'body': "You've been consistent for {streak} days. Don't let today be the break."},
      {'title': 'Save your streak', 'body': '{streak} days. Gone if you sleep without doing one thing. ONE thing.'},
      {'title': 'Warning', 'body': 'The chain is {streak} days long. Breaking it costs you more than keeping it.'},
      {'title': 'Clock ticking', 'body': '{streak}-day streak. Hours left. Even reading one page counts.'},
      {'title': 'Last chance', 'body': "It's getting late. {streak}-day streak needs ONE task before midnight."},
      {'title': 'Don\'t', 'body': "Don't let {streak} days of work die for one lazy evening. You're better than that."},
      {'title': 'Protect the streak', 'body': '{streak} consecutive days. Most people never get past 3. Protect this.'},
    ],
    'comeback': [
      {'title': 'Hey stranger', 'body': "It's been {daysAway} days. No judgment. The plan is still here."},
      {'title': 'We miss you', 'body': '{daysAway} days away. Your Week {week} tasks are collecting dust.'},
      {'title': 'Still your plan', 'body': "Life happened. {daysAway} days passed. But the plan didn't leave."},
      {'title': 'Welcome back?', 'body': 'Just open the app. Look at one task. No pressure beyond that.'},
      {'title': 'No judgment', 'body': "Everyone falls off. The ones who make it? They come back. Come back."},
      {'title': 'One task', 'body': "Forget the {daysAway} days. Today is day 1. Pick one task. Any task."},
      {'title': 'Still here', 'body': "The cloud isn't going anywhere. Neither is your plan. Start small."},
      {'title': 'Real talk', 'body': '{daysAway} days is nothing in the grand scheme. But today matters. Start.'},
      {'title': 'Restart', 'body': "Every expert was once a quitter who came back. Come back."},
      {'title': 'Your call', 'body': "The plan waited {daysAway} days. It'll wait more. But will you?"},
      {'title': 'Dust off', 'body': "Week {week} is still open. {pendingTasks} tasks. Start with literally any one."},
      {'title': 'Miss you', 'body': "Your {phase} phase tasks are lonely. Visit them. Just once."},
    ],
    'overwhelm_comfort': [
      {'title': 'Breathe', 'body': 'Ignore the full list. Pick literally ONE task. Just one.'},
      {'title': 'Too much?', 'body': "The plan looks big. But you only need to do the NEXT thing. That's it."},
      {'title': 'Simplify', 'body': 'Forget the week. Forget the plan. What is ONE thing you can do in 10 min?'},
      {'title': 'Permission granted', 'body': "You're allowed to do the bare minimum today. One task. Done. Rest."},
      {'title': 'Scale down', 'body': '{pendingTasks} tasks looks scary. But task #1 is just one thing. Start there.'},
      {'title': 'No hero mode', 'body': "You don't have to catch up today. Just don't fall further behind. One task."},
      {'title': 'Overwhelmed?', 'body': "That's normal. The plan is ambitious. Pick the easiest task. Do only that."},
      {'title': 'Just one', 'body': "If you could only do ONE task this entire week, which would it be? Do that one."},
      {'title': 'Baby steps', 'body': 'Behind schedule? Fine. Do one tiny thing. Progress is progress.'},
      {'title': 'Relax', 'body': "The plan is a guide, not a prison. Do what you can. That's enough."},
      {'title': 'Easy mode', 'body': "Scan the task list. Find the one that takes 5 minutes. Do it. Victory."},
      {'title': 'It\'s OK', 'body': "Behind by {pendingTasks} tasks? So what. Do one. You're still ahead of yesterday."},
    ],
    'task_specific': [
      {'title': 'Next up', 'body': "Next: '{nextTask}' -- start there."},
      {'title': 'Your move', 'body': "'{nextTask}' is waiting. How long could it really take?"},
      {'title': 'Queued', 'body': "Task ready: '{nextTask}'. Open. Do. Check off. Simple."},
      {'title': 'Focus target', 'body': "Forget everything else. Just do: '{nextTask}'"},
      {'title': 'One thing', 'body': "If you do nothing else today, do this: '{nextTask}'"},
      {'title': 'Locked target', 'body': "'{nextTask}' -- that's your mission. Accept it."},
      {'title': 'Task brief', 'body': "Week {week}, {phase} phase. Target: '{nextTask}'"},
      {'title': 'Do this', 'body': "Stop scrolling. Start doing: '{nextTask}'"},
      {'title': 'Action item', 'body': "'{nextTask}' -- you added this task for a reason. Honor that."},
      {'title': 'The one', 'body': "Out of {pendingTasks} pending tasks, start with: '{nextTask}'"},
    ],
    'milestone': [
      {'title': 'PHASE COMPLETE', 'body': '{phase} is DONE. Welcome to what comes next.'},
      {'title': 'Level up', 'body': 'You finished an entire phase. {phase} complete. Boss energy.'},
      {'title': 'Milestone', 'body': 'Week {week} complete. {progress}% overall. You are ahead of schedule.'},
      {'title': 'New phase', 'body': 'Entering {phase}. New skills. New challenges. Same grind.'},
      {'title': 'Achievement unlocked', 'body': '100% on Week {week}. Not many people can say that.'},
      {'title': 'Phase shift', 'body': '{phase} phase begins. The foundation you built? It pays off now.'},
      {'title': 'Major W', 'body': 'Another week in the books. {progress}% through the entire plan.'},
      {'title': 'Checkpoint', 'body': 'Week {week} done. You are exactly where you need to be.'},
      {'title': 'Half way', 'body': "50%+ complete. You're past the point of no return. Finish this."},
      {'title': 'Almost there', 'body': '{progress}% done. The finish line is visible. Keep pushing.'},
    ],
    'friday_build': [
      {'title': "It's BUILD DAY", 'body': "It's Friday. Your chance to knock a task out NOW."},
      {'title': 'Friday. Terminal. Now.', 'body': "Everyone's out. You're building. That's the difference."},
      {'title': 'Build day is here', 'body': "If you don't build today you'll regret it Saturday."},
      {'title': 'Your weekend mission', 'body': 'One docker-compose up. One terraform apply. Start somewhere.'},
      {'title': 'Time to ship', 'body': 'The guys who got out? They worked their Fridays.'},
      {'title': 'Friday prayer done?', 'body': 'Good. Now pray your code compiles. Open the terminal.'},
      {'title': 'Build mode ON', 'body': 'Stop planning. Start building. The laptop is right there.'},
      {'title': 'Friday fuel', 'body': "Week {week}, {phase} phase. {pendingTasks} tasks waiting. Let's go."},
      {'title': 'Scaffold day', 'body': "Today you scaffold. Tomorrow you deploy. That's the system."},
      {'title': 'Your future', 'body': 'Your future self is watching. Make him proud this Friday.'},
      {'title': 'Build or bust', 'body': 'Every Friday you skip = one more month stuck. Build something.'},
      {'title': 'Friday check', 'body': "It's past noon. Have you started yet? '{nextTask}' awaits."},
      {'title': 'Hands on keys', 'body': '{pendingTasks} Friday tasks. Pick one. Code it. Check it off.'},
      {'title': 'TGIF?', 'body': "TGIF hits different when F means 'build day'. Get after it."},
      {'title': 'Build day brief', 'body': "Phase: {phase}. Week: {week}. Mission: build. Status: let's go."},
    ],
    'saturday_deploy': [
      {'title': 'DEPLOY DAY', 'body': 'Deploy what you built yesterday or it never happened.'},
      {'title': 'Ship it Saturday', 'body': 'Deploy, test, break it, fix it. Start the loop.'},
      {'title': 'Break things today', 'body': "If nothing breaks, you're not pushing hard enough."},
      {'title': 'Deploy or regret it', 'body': "Two days a week. That's all you have. Don't blow this one."},
      {'title': 'Saturday mission', 'body': 'Push to prod or it never happened.'},
      {'title': 'Ship day', 'body': "Your LinkedIn still says nothing about cloud. Fix that today."},
      {'title': "Saturday's half gone", 'body': "What did you deploy? '{nextTask}' is still unchecked."},
      {'title': 'Deploy mode', 'body': 'The cert won\'t pass itself. The cluster won\'t deploy itself. GO.'},
      {'title': 'Test day', 'body': 'Saturday = test what you built. Break it on purpose. Learn why.'},
      {'title': 'Last chance', 'body': "Saturday evening. {pendingTasks} tasks left. Tomorrow is work day."},
      {'title': 'Deploy brief', 'body': 'Week {week}, {phase}. Deploy target: get something live.'},
      {'title': 'No more planning', 'body': "You planned Friday. Saturday is for shipping. SHIP."},
      {'title': 'Tick tock', 'body': 'Weekend almost over. {pendingTasks} tasks won\'t do themselves.'},
      {'title': 'Push it', 'body': 'git push origin main. Or whatever your deploy looks like. Do it.'},
      {'title': 'Final push', 'body': "Saturday night. Last chance this week. Make it count."},
    ],
    'weeknight_study': [
      {'title': "SAA-C03 won't pass itself", 'body': "Everyone's on Netflix. You're not everyone. Open the course."},
      {'title': 'Study time. No excuses.', 'body': "Skip tonight and you'll skip tomorrow too. You know how this goes."},
      {'title': '25 min. That\'s all.', 'body': "Shorter than a sitcom episode. Just do it."},
      {'title': 'Open the course. NOW.', 'body': 'The people who got hired last month studied on nights like this.'},
      {'title': 'Your future called.', 'body': "Even 1 practice question tonight > 0. Don't break the chain."},
      {'title': 'Study night', 'body': 'You said you wanted out. This is what out looks like. Study.'},
      {'title': 'Exam countdown', 'body': "The exam date isn't moving. Are you? {examDays} days left."},
      {'title': 'Tired? Good.', 'body': 'Study tired. It still counts. 25 minutes. Go.'},
      {'title': 'Skip = stuck', 'body': 'Every skipped night = 1 more week stuck exactly where you are.'},
      {'title': 'Before bed', 'body': '15 min before bed. Nothing. You waste more scrolling Twitter.'},
      {'title': 'Night owl mode', 'body': "It's quiet. Perfect study conditions. {examDays} days to exam."},
      {'title': 'Quick session', 'body': 'One Pomodoro. 25 min. Then you can rest guilt-free.'},
      {'title': 'Consistency', 'body': '{streak} days in a row. Tonight makes it {streak}+1. Keep going.'},
      {'title': 'AWS awaits', 'body': 'SAA-C03. The cert that changes your resume. Study tonight.'},
      {'title': 'Evening ritual', 'body': 'Sun-Thu evenings = study time. No exceptions. Open the course.'},
    ],
  };

  // Mood weights per engagement state
  static const _moodWeights = <String, Map<String, double>>{
    'engaged': {
      'celebrate': 0.40,
      'task_specific': 0.25,
      'milestone': 0.15,
      'gentle_nudge': 0.10,
      'friday_build': 0.05,
      'saturday_deploy': 0.05,
    },
    'coasting': {
      'gentle_nudge': 0.30,
      'task_specific': 0.25,
      'streak_warning': 0.15,
      'friday_build': 0.10,
      'saturday_deploy': 0.10,
      'weeknight_study': 0.10,
    },
    'slipping': {
      'streak_warning': 0.25,
      'gentle_nudge': 0.20,
      'task_specific': 0.20,
      'friday_build': 0.12,
      'saturday_deploy': 0.13,
      'weeknight_study': 0.10,
    },
    'absent': {
      'comeback': 0.40,
      'gentle_nudge': 0.20,
      'overwhelm_comfort': 0.15,
      'task_specific': 0.15,
      'weeknight_study': 0.10,
    },
    'ghosting': {
      'comeback': 0.50,
      'overwhelm_comfort': 0.25,
      'gentle_nudge': 0.15,
      'task_specific': 0.10,
    },
  };

  static String pickMood(String engagementState, String? lastMood, {bool isFriday = false, bool isSaturday = false, bool isWeeknight = false, bool isOverwhelmed = false}) {
    if (isOverwhelmed) {
      // 50% chance of overwhelm_comfort, rest distributed
      if (_rng.nextDouble() < 0.5) return 'overwhelm_comfort';
    }

    // Force day-specific moods on build days / weeknights
    if (isFriday && _rng.nextDouble() < 0.5) return 'friday_build';
    if (isSaturday && _rng.nextDouble() < 0.5) return 'saturday_deploy';
    if (isWeeknight && _rng.nextDouble() < 0.4) return 'weeknight_study';

    final weights = _moodWeights[engagementState] ?? _moodWeights['coasting']!;
    final entries = weights.entries.toList();
    final total = entries.fold<double>(0, (sum, e) => sum + e.value);
    var roll = _rng.nextDouble() * total;

    String picked = entries.first.key;
    for (final entry in entries) {
      roll -= entry.value;
      if (roll <= 0) {
        picked = entry.key;
        break;
      }
    }

    // Avoid repeating last mood
    if (picked == lastMood && entries.length > 1) {
      final alternatives = entries.where((e) => e.key != lastMood).toList();
      picked = alternatives[_rng.nextInt(alternatives.length)].key;
    }

    return picked;
  }

  static Map<String, String> pickTemplate(String mood, Map<String, String> tokens) {
    final templates = _templates[mood];
    if (templates == null || templates.isEmpty) {
      return {'title': 'Cloud Study', 'body': 'Time to study!'};
    }

    final template = templates[_rng.nextInt(templates.length)];
    return {
      'title': _resolveTokens(template['title']!, tokens),
      'body': _resolveTokens(template['body']!, tokens),
    };
  }

  static String _resolveTokens(String text, Map<String, String> tokens) {
    var result = text;
    for (final entry in tokens.entries) {
      result = result.replaceAll('{${entry.key}}', entry.value);
    }
    return result;
  }
}
