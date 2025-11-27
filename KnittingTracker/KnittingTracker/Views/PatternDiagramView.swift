import SwiftUI

struct PatternDiagramView: View {
    let currentRow: Int

    var body: some View {
        Canvas { context, size in
            let gridSize: CGFloat = 20
            let rows = 8
            let cols = Int(size.width / gridSize)

            for row in 0..<rows {
                for col in 0..<cols {
                    let rect = CGRect(x: CGFloat(col) * gridSize, y: CGFloat(row) * gridSize, width: gridSize, height: gridSize)

                    if row == currentRow % 8 {
                        context.fill(Path(rect), with: .color(.blue.opacity(0.2)))
                    }

                    context.stroke(Path(rect), with: .color(.gray.opacity(0.3)), lineWidth: 0.5)

                    let symbol = symbolForCell(row: row, col: col)
                    drawSymbol(context: context, symbol: symbol, in: rect)
                }

                let rowNumber = Text("\(row + 1)")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                context.draw(rowNumber, at: CGPoint(x: size.width - 15, y: CGFloat(row) * gridSize + gridSize / 2))
            }
        }
    }

    private func symbolForCell(row: Int, col: Int) -> String {
        let patterns = ["•", "−", "○", "•", "•", "−"]
        return patterns[(row + col) % patterns.count]
    }

    private func drawSymbol(context: GraphicsContext, symbol: String, in rect: CGRect) {
        let text = Text(symbol)
            .font(.system(size: 12))
            .foregroundColor(.primary)
        context.draw(text, at: CGPoint(x: rect.midX, y: rect.midY))
    }
}