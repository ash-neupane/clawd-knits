import Foundation
import SwiftUI

// MARK: - Knitting Project Model

struct KnittingProject: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var sections: [ProjectSection]
    var notes: String
    var imageData: Data?
    var createdAt: Date
    var updatedAt: Date

    /// Calculates overall progress across all sections
    var overallProgress: Double {
        guard !sections.isEmpty else { return 0 }
        let total = sections.reduce(0.0) { $0 + $1.progress }
        return total / Double(sections.count)
    }

    /// Returns the first incomplete section
    var activeSection: ProjectSection? {
        sections.first { $0.currentRow < $0.totalRows }
    }

    init(id: UUID = UUID(), name: String, description: String, sections: [ProjectSection], notes: String = "", imageData: Data? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.sections = sections
        self.notes = notes
        self.imageData = imageData
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - Project Section Model

struct ProjectSection: Identifiable, Codable {
    let id: UUID
    var name: String
    var currentRow: Int
    var totalRows: Int
    var patternInstructions: String
    var notes: String
    var stitchCount: Int?

    /// Calculates progress percentage (0-100)
    var progress: Double {
        guard totalRows > 0 else { return 0 }
        return Double(currentRow) / Double(totalRows) * 100
    }

    /// Returns true if all rows are completed
    var isComplete: Bool {
        currentRow >= totalRows
    }

    init(id: UUID = UUID(), name: String, currentRow: Int = 0, totalRows: Int, patternInstructions: String, notes: String = "", stitchCount: Int? = nil) {
        self.id = id
        self.name = name
        self.currentRow = currentRow
        self.totalRows = totalRows
        self.patternInstructions = patternInstructions
        self.notes = notes
        self.stitchCount = stitchCount
    }
}

// MARK: - Stitch Symbol Enum

enum StitchSymbol: String, CaseIterable {
    case knit = "•"
    case purl = "−"
    case yarnOver = "○"
    case knitTwoTogether = "/"
    case slipSlipKnit = "\\"
    case cableCross = "⌄"

    var description: String {
        switch self {
        case .knit: return "Knit stitch"
        case .purl: return "Purl stitch"
        case .yarnOver: return "Yarn over"
        case .knitTwoTogether: return "K2tog (decrease)"
        case .slipSlipKnit: return "SSK (decrease)"
        case .cableCross: return "Cable cross"
        }
    }

    var systemImage: String {
        switch self {
        case .knit: return "circle.fill"
        case .purl: return "minus"
        case .yarnOver: return "circle"
        case .knitTwoTogether: return "arrow.right"
        case .slipSlipKnit: return "arrow.left"
        case .cableCross: return "arrow.triangle.2.circlepath"
        }
    }
}