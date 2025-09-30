import SwiftUI

struct ProjectRowView: View {
    let project: KnittingProject

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(project.name)
                        .font(.headline)
                    Text(project.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text("\(Int(project.overallProgress))%")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(progressColor.opacity(0.2))
                    .foregroundColor(progressColor)
                    .cornerRadius(8)
            }

            ProgressView(value: project.overallProgress, total: 100)
                .tint(progressColor)

            HStack {
                if let activeSection = project.activeSection {
                    Text(activeSection.name)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.accentColor.opacity(0.1))
                        .cornerRadius(4)
                }

                Spacer()

                Text("Updated \(timeAgo(project.updatedAt))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private var progressColor: Color {
        switch project.overallProgress {
        case 0..<25: return .red
        case 25..<50: return .orange
        case 50..<75: return .blue
        case 75..<100: return .green
        default: return .green
        }
    }

    private func timeAgo(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}