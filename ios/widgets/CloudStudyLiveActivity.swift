import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Live Activity Attributes

struct CloudStudyActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var elapsedMinutes: Int
        var totalMinutes: Int
        var tasksCompleted: Int
        var tasksTotal: Int
        var motivation: String
    }

    var sessionType: String   // "build", "deploy", "study"
    var weekNumber: Int
    var weekTitle: String
    var phase: String
}

// MARK: - Live Activity Widget

struct CloudStudyLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CloudStudyActivityAttributes.self) { context in
            // Lock Screen / Notification banner
            LockScreenLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded view
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("W\(context.attributes.weekNumber)")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(phaseColor(context.attributes.phase))
                            .cornerRadius(4)

                        Text(sessionLabel(context.attributes.sessionType))
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                }

                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        let progress = context.state.totalMinutes > 0
                            ? Double(context.state.elapsedMinutes) / Double(context.state.totalMinutes)
                            : 0.0

                        Text("\(context.state.elapsedMinutes)/\(context.state.totalMinutes)m")
                            .font(.system(size: 16, weight: .bold, design: .monospaced))

                        Text("\(Int(progress * 100))%")
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundColor(phaseColor(context.attributes.phase))
                    }
                }

                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.motivation)
                        .font(.system(size: 12, weight: .medium))
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .padding(.top, 2)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    let progress = context.state.totalMinutes > 0
                        ? Double(context.state.elapsedMinutes) / Double(context.state.totalMinutes)
                        : 0.0
                    let color = phaseColor(context.attributes.phase)

                    VStack(spacing: 6) {
                        ProgressView(value: progress)
                            .tint(color)

                        HStack {
                            Label("\(context.state.tasksCompleted)/\(context.state.tasksTotal)", systemImage: "checkmark.circle.fill")
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundColor(.secondary)

                            Spacer()

                            Text(context.attributes.weekTitle)
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
            } compactLeading: {
                // Compact left — phase badge
                let color = phaseColor(context.attributes.phase)
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                    Text(sessionIcon(context.attributes.sessionType))
                        .font(.system(size: 12))
                }
                .frame(width: 24, height: 24)
            } compactTrailing: {
                // Compact right — timer
                let progress = context.state.totalMinutes > 0
                    ? Double(context.state.elapsedMinutes) / Double(context.state.totalMinutes)
                    : 0.0

                Text("\(context.state.elapsedMinutes)m")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(phaseColor(context.attributes.phase))
            } minimal: {
                // Minimal — just a progress ring
                let progress = context.state.totalMinutes > 0
                    ? Double(context.state.elapsedMinutes) / Double(context.state.totalMinutes)
                    : 0.0
                let color = phaseColor(context.attributes.phase)

                ZStack {
                    Circle()
                        .stroke(color.opacity(0.3), lineWidth: 2)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(color, lineWidth: 2)
                        .rotationEffect(.degrees(-90))
                }
                .frame(width: 16, height: 16)
            }
        }
    }

    func sessionLabel(_ type: String) -> String {
        switch type {
        case "build": return "BUILD"
        case "deploy": return "DEPLOY"
        case "study": return "SAA STUDY"
        default: return "SESSION"
        }
    }

    func sessionIcon(_ type: String) -> String {
        switch type {
        case "build": return "🔨"
        case "deploy": return "🚀"
        case "study": return "📖"
        default: return "⚡"
        }
    }
}

// MARK: - Lock Screen Live Activity

struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<CloudStudyActivityAttributes>

    var body: some View {
        let color = phaseColor(context.attributes.phase)
        let progress = context.state.totalMinutes > 0
            ? Double(context.state.elapsedMinutes) / Double(context.state.totalMinutes)
            : 0.0

        HStack(spacing: 14) {
            // Progress ring
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 5)
                    .frame(width: 50, height: 50)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(color, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))

                Text("\(context.state.elapsedMinutes)m")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("W\(context.attributes.weekNumber)")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(color)
                        .cornerRadius(4)

                    Text(sessionLabel(context.attributes.sessionType))
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(color)

                    Spacer()

                    Text("\(context.state.tasksCompleted)/\(context.state.tasksTotal)")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(color)
                }

                Text(context.state.motivation)
                    .font(.system(size: 12, weight: .medium))
                    .lineLimit(1)

                ProgressView(value: progress)
                    .tint(color)
            }
        }
        .padding(16)
        .activityBackgroundTint(.black.opacity(0.7))
        .activitySystemActionForegroundColor(.white)
    }

    func sessionLabel(_ type: String) -> String {
        switch type {
        case "build": return "BUILD"
        case "deploy": return "DEPLOY"
        case "study": return "SAA STUDY"
        default: return "SESSION"
        }
    }
}
