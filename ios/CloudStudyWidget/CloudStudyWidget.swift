import WidgetKit
import SwiftUI

// MARK: - Data Model

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
        // Update every 30 minutes for fresh motivation messages
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
            updatedAt: ""
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

// MARK: - Small Widget

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

            // Progress bar
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
            // Left: progress ring
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

                // Progress bar
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

// MARK: - Large Widget

struct LargeWidgetView: View {
    let data: WidgetData

    var body: some View {
        let color = phaseColor(data.weekPhase)

        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("CLOUD STUDY")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.secondary)
                        .tracking(2)

                    Text("10-Week Battle Plan")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                }

                Spacer()

                ZStack {
                    Circle()
                        .stroke(color.opacity(0.15), lineWidth: 5)
                        .frame(width: 50, height: 50)

                    Circle()
                        .trim(from: 0, to: data.overallProgress)
                        .stroke(color, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(-90))

                    Text("\(Int(data.overallProgress * 100))%")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
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

                Text("\(data.weekCompleted)/\(data.weekTotal)")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(color)
            }

            Text(data.weekTitle)
                .font(.system(size: 15, weight: .bold, design: .monospaced))

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(color.opacity(0.12))
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(color)
                        .frame(width: geo.size.width * data.weekProgress, height: 6)
                }
            }
            .frame(height: 6)

            Divider()

            // Motivation
            Text(data.motivation)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.primary)
                .lineLimit(3)

            Spacer()

            // Stats
            HStack(spacing: 16) {
                _StatView(label: "Tasks", value: "\(data.completedTasks)/\(data.totalTasks)", color: .blue)
                _StatView(label: "Exam", value: data.examDaysLeft >= 0 ? "\(data.examDaysLeft)d" : "—", color: .red)
                _StatView(label: "Week", value: "\(data.currentWeek)/10", color: color)
            }
        }
        .padding(16)
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }
}

struct _StatView: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(color.opacity(0.08))
        .cornerRadius(8)
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

// MARK: - Widget Bundle

@main
struct CloudStudyWidgets: WidgetBundle {
    var body: some Widget {
        CloudStudyMainWidget()
        CloudStudyLockCircular()
        CloudStudyLockRectangular()
        CloudStudyLockInline()
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
        updatedAt: ""
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
        updatedAt: ""
    ))
}
