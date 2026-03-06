import WidgetKit
import SwiftUI

// MARK: - Data Models

struct WidgetTask: Codable {
    let text: String
    let completed: Bool
}

struct WidgetData: Codable {
    let overallProgress: Double
    let totalTasks: Int
    let completedTasks: Int
    let currentWeek: Int
    let weekTitle: String
    let weekPhase: String
    let weekProgress: Double
    let weekCompleted: Int
    let weekTotal: Int
    let examDaysLeft: Int
    let motivation: String
    let updatedAt: String

    // New fields with backward-compatible defaults
    let streak: Int?
    let dayType: String?
    let saaTopic: String?
    let todayTasks: [WidgetTask]?
    let nextTask: String?

    var safeStreak: Int { streak ?? 0 }
    var safeDayType: String { dayType ?? "weeknight" }
    var safeTodayTasks: [WidgetTask] { todayTasks ?? [] }
    var safeNextTask: String { nextTask ?? "" }
    var safeSaaTopic: String { saaTopic ?? "" }
}

// MARK: - Timeline Provider

struct CloudStudyProvider: TimelineProvider {
    let appGroup = "group.com.cloudstudy.widgets"

    func placeholder(in context: Context) -> CloudStudyEntry {
        CloudStudyEntry(date: Date(), data: sampleData)
    }

    func getSnapshot(in context: Context, completion: @escaping (CloudStudyEntry) -> Void) {
        completion(CloudStudyEntry(date: Date(), data: loadData()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CloudStudyEntry>) -> Void) {
        let data = loadData()
        let entry = CloudStudyEntry(date: Date(), data: data)
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    func loadData() -> WidgetData {
        guard let defaults = UserDefaults(suiteName: appGroup),
              let jsonString = defaults.string(forKey: "widgetData"),
              let jsonData = jsonString.data(using: .utf8),
              let data = try? JSONDecoder().decode(WidgetData.self, from: jsonData) else {
            return sampleData
        }
        return data
    }

    var sampleData: WidgetData {
        WidgetData(
            overallProgress: 0.0,
            totalTasks: 89,
            completedTasks: 0,
            currentWeek: 1,
            weekTitle: "Docker + Your First API",
            weekPhase: "CONTAINERS",
            weekProgress: 0.0,
            weekCompleted: 0,
            weekTotal: 9,
            examDaysLeft: 49,
            motivation: "Open the app. Set your start date. Begin.",
            updatedAt: "",
            streak: 0,
            dayType: "weeknight",
            saaTopic: "AWS fundamentals",
            todayTasks: [],
            nextTask: ""
        )
    }
}

struct CloudStudyEntry: TimelineEntry {
    let date: Date
    let data: WidgetData
}

// MARK: - Phase Colors

func phaseColor(_ phase: String) -> Color {
    switch phase {
    case "CONTAINERS": return Color(hex: "0EA5E9")
    case "INFRASTRUCTURE": return Color(hex: "6366F1")
    case "AUTOMATION": return Color(hex: "F59E0B")
    case "CERT": return Color(hex: "EF4444")
    case "CAPSTONE": return Color(hex: "10B981")
    case "LAUNCH": return Color(hex: "D946EF")
    default: return .blue
    }
}

func phaseBg(_ phase: String) -> Color {
    switch phase {
    case "CONTAINERS": return Color(hex: "EFF6FF")
    case "INFRASTRUCTURE": return Color(hex: "EEF2FF")
    case "AUTOMATION": return Color(hex: "FFFBEB")
    case "CERT": return Color(hex: "FEF2F2")
    case "CAPSTONE": return Color(hex: "ECFDF5")
    case "LAUNCH": return Color(hex: "FDF4FF")
    default: return Color(hex: "EFF6FF")
    }
}

func dayTypeLabel(_ dayType: String) -> String {
    switch dayType {
    case "friday": return "BUILD FRIDAY"
    case "saturday": return "DEPLOY SATURDAY"
    default: return "STUDY NIGHT"
    }
}

func dayTypeIcon(_ dayType: String) -> String {
    switch dayType {
    case "friday": return "hammer.fill"
    case "saturday": return "paperplane.fill"
    default: return "book.fill"
    }
}

// MARK: - Small Widget (Overview)

struct SmallWidgetView: View {
    let data: WidgetData

    var body: some View {
        let color = phaseColor(data.weekPhase)

        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("W\(data.currentWeek)")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(color)
                    .cornerRadius(4)

                Spacer()

                Text("\(Int(data.overallProgress * 100))%")
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(color)
            }

            Text(data.weekTitle)
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .lineLimit(2)
                .foregroundColor(.primary)

            Spacer()

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(color.opacity(0.15))
                        .frame(height: 5)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(color)
                        .frame(width: geo.size.width * data.weekProgress, height: 5)
                }
            }
            .frame(height: 5)

            Text("\(data.weekCompleted)/\(data.weekTotal) tasks")
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(.secondary)
        }
        .padding(14)
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }
}

// MARK: - Medium Widget (Motivation)

struct MediumWidgetView: View {
    let data: WidgetData

    var body: some View {
        let color = phaseColor(data.weekPhase)

        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.15), lineWidth: 6)
                    .frame(width: 64, height: 64)

                Circle()
                    .trim(from: 0, to: data.overallProgress)
                    .stroke(color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 64, height: 64)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 0) {
                    Text("\(Int(data.overallProgress * 100))%")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                    Text("done")
                        .font(.system(size: 8, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("W\(data.currentWeek)")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(color)
                        .cornerRadius(4)

                    Text(data.weekPhase)
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(color)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(color.opacity(0.1))
                        .cornerRadius(4)

                    Spacer()

                    if data.examDaysLeft >= 0 {
                        Text("\(data.examDaysLeft)d")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.red)
                    }
                }

                Text(data.motivation)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(color.opacity(0.12))
                            .frame(height: 4)

                        RoundedRectangle(cornerRadius: 3)
                            .fill(color)
                            .frame(width: geo.size.width * data.weekProgress, height: 4)
                    }
                }
                .frame(height: 4)
            }
        }
        .padding(16)
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }
}

// MARK: - Large Widget (now shows today's tasks)

struct LargeWidgetView: View {
    let data: WidgetData

    var body: some View {
        let color = phaseColor(data.weekPhase)
        let tasks = data.safeTodayTasks
        let todayDone = tasks.filter { $0.completed }.count

        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("CLOUD STUDY")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.secondary)
                        .tracking(2)

                    Text(dayTypeLabel(data.safeDayType))
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(color)
                }

                Spacer()

                ZStack {
                    Circle()
                        .stroke(color.opacity(0.15), lineWidth: 5)
                        .frame(width: 46, height: 46)

                    Circle()
                        .trim(from: 0, to: data.overallProgress)
                        .stroke(color, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                        .frame(width: 46, height: 46)
                        .rotationEffect(.degrees(-90))

                    Text("\(Int(data.overallProgress * 100))%")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                }
            }

            Divider()

            // Current week
            HStack {
                Text("W\(data.currentWeek)")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(color)
                    .cornerRadius(5)

                Text(data.weekPhase)
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(color)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(color.opacity(0.1))
                    .cornerRadius(5)

                Spacer()

                if !tasks.isEmpty {
                    Text("\(todayDone)/\(tasks.count) today")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(todayDone == tasks.count ? .green : color)
                } else {
                    Text("\(data.weekCompleted)/\(data.weekTotal)")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(color)
                }
            }

            // Tasks or SAA topic
            if !tasks.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(tasks.prefix(6).enumerated()), id: \.offset) { _, task in
                        HStack(spacing: 6) {
                            Image(systemName: task.completed ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 12))
                                .foregroundColor(task.completed ? .green : color.opacity(0.5))

                            Text(task.text)
                                .font(.system(size: 11, weight: .medium))
                                .lineLimit(1)
                                .foregroundColor(task.completed ? .secondary : .primary)
                                .strikethrough(task.completed)
                        }
                    }
                    if tasks.count > 6 {
                        Text("+\(tasks.count - 6) more")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
            } else {
                // Weeknight: show SAA topic
                if !data.safeSaaTopic.isEmpty {
                    Text(data.safeSaaTopic)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.primary)
                        .lineLimit(3)
                }

                Text(data.motivation)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            // Stats row
            HStack(spacing: 12) {
                StatChip(label: "Streak", value: "\(data.safeStreak)", icon: "flame.fill", color: .orange)
                StatChip(label: "Exam", value: data.examDaysLeft >= 0 ? "\(data.examDaysLeft)d" : "-", icon: "calendar", color: .red)
                StatChip(label: "Week", value: "\(data.currentWeek)/10", icon: "chart.bar.fill", color: color)
            }
        }
        .padding(16)
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }
}

struct StatChip: View {
    let label: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            HStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 9))
                    .foregroundColor(color)
                Text(value)
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(color)
            }
            Text(label)
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 5)
        .background(color.opacity(0.08))
        .cornerRadius(8)
    }
}

// MARK: - Next Task Widget (Small)

struct NextTaskWidgetView: View {
    let data: WidgetData

    var body: some View {
        let color = phaseColor(data.weekPhase)
        let nextTask = data.safeNextTask

        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: dayTypeIcon(data.safeDayType))
                    .font(.system(size: 12))
                    .foregroundColor(color)
                Text(data.weekPhase)
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(color)
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(color.opacity(0.1))
            .cornerRadius(4)

            Text("NEXT UP")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(.secondary)
                .tracking(1)

            if nextTask.isEmpty {
                Text("All done!")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(.green)
            } else {
                Text(nextTask)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(3)
            }

            Spacer()
        }
        .padding(14)
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }
}

// MARK: - Streak Widget (Small)

struct StreakWidgetView: View {
    let data: WidgetData

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .font(.system(size: 28))
                .foregroundColor(.orange)

            Text("\(data.safeStreak)")
                .font(.system(size: 32, weight: .bold, design: .monospaced))
                .foregroundColor(.orange)

            Text("day streak")
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }
}

// MARK: - Motivation Widget (Small)

struct MotivationWidgetView: View {
    let data: WidgetData

    var body: some View {
        let color = phaseColor(data.weekPhase)

        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: "quote.opening")
                .font(.system(size: 14))
                .foregroundColor(color.opacity(0.5))

            Text(data.motivation)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.primary)
                .lineLimit(4)

            Spacer()

            HStack {
                Spacer()
                Text("W\(data.currentWeek)")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(color)
            }
        }
        .padding(14)
        .containerBackground(for: .widget) {
            color.opacity(0.05)
        }
    }
}

// MARK: - Lock Screen Widgets

struct LockScreenCircularView: View {
    let data: WidgetData

    var body: some View {
        Gauge(value: data.overallProgress) {
            Text("CS")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
        } currentValueLabel: {
            Text("\(Int(data.overallProgress * 100))")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
        }
        .gaugeStyle(.accessoryCircular)
    }
}

struct LockScreenRectangularView: View {
    let data: WidgetData

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("W\(data.currentWeek) · \(data.weekPhase)")
                .font(.system(size: 11, weight: .bold, design: .monospaced))

            Text(data.motivation)
                .font(.system(size: 11))
                .lineLimit(2)

            Gauge(value: data.weekProgress) { }
                .gaugeStyle(.accessoryLinear)
        }
    }
}

struct LockScreenInlineView: View {
    let data: WidgetData

    var body: some View {
        Text("W\(data.currentWeek) \(Int(data.overallProgress * 100))% · \(data.weekCompleted)/\(data.weekTotal) tasks")
            .font(.system(size: 12, weight: .medium, design: .monospaced))
    }
}

// MARK: - Today Lock Screen Rectangular

struct TodayLockRectView: View {
    let data: WidgetData

    var body: some View {
        let tasks = data.safeTodayTasks
        let todayDone = tasks.filter { $0.completed }.count
        let todayTotal = max(tasks.count, 1)

        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(dayTypeLabel(data.safeDayType))
                    .font(.system(size: 10, weight: .bold, design: .monospaced))

                Spacer()

                if !tasks.isEmpty {
                    Text("\(todayDone)/\(tasks.count)")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                }
            }

            if !data.safeNextTask.isEmpty {
                Text(data.safeNextTask)
                    .font(.system(size: 11))
                    .lineLimit(1)
            } else {
                Text("All tasks done!")
                    .font(.system(size: 11))
            }

            Gauge(value: tasks.isEmpty ? data.weekProgress : Double(todayDone) / Double(todayTotal)) { }
                .gaugeStyle(.accessoryLinear)
        }
    }
}

// MARK: - Widget Bundle (nested to support >4 widgets)

@main
struct CloudStudyWidgets: WidgetBundle {
    var body: some Widget {
        HomeWidgets()
        LockWidgets()
    }
}

struct HomeWidgets: WidgetBundle {
    var body: some Widget {
        CloudStudyMainWidget()
        CloudStudyNextTaskWidget()
        CloudStudyStreakWidget()
        CloudStudyMotivationWidget()
    }
}

struct LockWidgets: WidgetBundle {
    var body: some Widget {
        CloudStudyLockCircular()
        CloudStudyLockRectangular()
        CloudStudyLockInline()
        CloudStudyTodayLockRect()
    }
}

// MARK: - Main Widget (Small, Medium, Large)

struct CloudStudyMainWidget: Widget {
    let kind = "CloudStudyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CloudStudyProvider()) { entry in
            CloudStudyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Cloud Study")
        .description("Track your 10-week cloud engineering study plan")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct CloudStudyWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: CloudStudyEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(data: entry.data)
        case .systemMedium:
            MediumWidgetView(data: entry.data)
        case .systemLarge:
            LargeWidgetView(data: entry.data)
        default:
            SmallWidgetView(data: entry.data)
        }
    }
}

// MARK: - Next Task Widget

struct CloudStudyNextTaskWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "CloudStudyNextTask", provider: CloudStudyProvider()) { entry in
            NextTaskWidgetView(data: entry.data)
        }
        .configurationDisplayName("Next Task")
        .description("Your next uncompleted task")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Streak Widget

struct CloudStudyStreakWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "CloudStudyStreak", provider: CloudStudyProvider()) { entry in
            StreakWidgetView(data: entry.data)
        }
        .configurationDisplayName("Streak")
        .description("Your study streak")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Motivation Widget

struct CloudStudyMotivationWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "CloudStudyMotivation", provider: CloudStudyProvider()) { entry in
            MotivationWidgetView(data: entry.data)
        }
        .configurationDisplayName("Motivation")
        .description("Toxic motivation to keep you going")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Lock Screen Widgets

struct CloudStudyLockCircular: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "CloudStudyLockCircular", provider: CloudStudyProvider()) { entry in
            LockScreenCircularView(data: entry.data)
        }
        .configurationDisplayName("Progress Ring")
        .description("Overall study progress")
        .supportedFamilies([.accessoryCircular])
    }
}

struct CloudStudyLockRectangular: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "CloudStudyLockRectangular", provider: CloudStudyProvider()) { entry in
            LockScreenRectangularView(data: entry.data)
        }
        .configurationDisplayName("Study Status")
        .description("Current week & motivation")
        .supportedFamilies([.accessoryRectangular])
    }
}

struct CloudStudyLockInline: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "CloudStudyLockInline", provider: CloudStudyProvider()) { entry in
            LockScreenInlineView(data: entry.data)
        }
        .configurationDisplayName("Quick Stats")
        .description("Progress at a glance")
        .supportedFamilies([.accessoryInline])
    }
}

struct CloudStudyTodayLockRect: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "CloudStudyTodayLockRect", provider: CloudStudyProvider()) { entry in
            TodayLockRectView(data: entry.data)
        }
        .configurationDisplayName("Today's Progress")
        .description("Today's tasks and next task")
        .supportedFamilies([.accessoryRectangular])
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        self.init(
            red: Double((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: Double((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgbValue & 0x0000FF) / 255.0
        )
    }
}

// MARK: - Previews

#Preview("Small", as: .systemSmall) {
    CloudStudyMainWidget()
} timeline: {
    CloudStudyEntry(date: Date(), data: WidgetData(
        overallProgress: 0.35,
        totalTasks: 89,
        completedTasks: 31,
        currentWeek: 4,
        weekTitle: "CI/CD Pipeline + GitHub Actions",
        weekPhase: "AUTOMATION",
        weekProgress: 0.6,
        weekCompleted: 5,
        weekTotal: 9,
        examDaysLeft: 21,
        motivation: "From git push to production in 4 minutes.",
        updatedAt: "",
        streak: 5,
        dayType: "friday",
        saaTopic: nil,
        todayTasks: [
            WidgetTask(text: "Set up GitHub Actions workflow", completed: true),
            WidgetTask(text: "Add Docker build step", completed: false),
        ],
        nextTask: "Add Docker build step"
    ))
}

#Preview("Medium", as: .systemMedium) {
    CloudStudyMainWidget()
} timeline: {
    CloudStudyEntry(date: Date(), data: WidgetData(
        overallProgress: 0.35,
        totalTasks: 89,
        completedTasks: 31,
        currentWeek: 4,
        weekTitle: "CI/CD Pipeline + GitHub Actions",
        weekPhase: "AUTOMATION",
        weekProgress: 0.6,
        weekCompleted: 5,
        weekTotal: 9,
        examDaysLeft: 21,
        motivation: "It's study time. Open the course. NOW.",
        updatedAt: "",
        streak: 5,
        dayType: "friday",
        saaTopic: nil,
        todayTasks: nil,
        nextTask: nil
    ))
}
