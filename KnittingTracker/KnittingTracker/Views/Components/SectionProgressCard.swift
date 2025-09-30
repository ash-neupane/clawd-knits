import SwiftUI

struct SectionProgressCard: View {
    let section: ProjectSection

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(section.name)
                    .font(.headline)
                Spacer()
                Text("\(Int(section.progress))%")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
            }

            ProgressView(value: section.progress, total: 100)
                .tint(.blue)

            if section.isComplete {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Section Complete!")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}