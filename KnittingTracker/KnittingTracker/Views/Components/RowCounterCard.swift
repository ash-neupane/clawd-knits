import SwiftUI

struct RowCounterCard: View {
    let section: ProjectSection
    let onIncrement: () -> Void
    let onDecrement: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Row Counter")
                .font(.headline)

            HStack(spacing: 32) {
                Button(action: onDecrement) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.blue)
                }
                .disabled(section.currentRow == 0)

                VStack(spacing: 4) {
                    Text("\(section.currentRow)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.blue)
                        .contentTransition(.numericText())
                    Text("of \(section.totalRows) rows")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Button(action: onIncrement) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.blue)
                }
                .disabled(section.currentRow >= section.totalRows)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}