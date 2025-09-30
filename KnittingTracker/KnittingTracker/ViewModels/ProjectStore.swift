import Foundation
import SwiftUI

@MainActor
class ProjectStore: ObservableObject {
    @Published var projects: [KnittingProject] = []

    private let saveKey = "SavedProjects"

    init() {
        loadProjects()
        if projects.isEmpty {
            loadSampleData()
        }
    }

    // MARK: - Project Management

    func addProject(_ project: KnittingProject) {
        projects.append(project)
        saveProjects()
    }

    func updateProject(_ project: KnittingProject) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            var updatedProject = project
            updatedProject.updatedAt = Date()
            projects[index] = updatedProject
            saveProjects()
        }
    }

    func deleteProject(_ project: KnittingProject) {
        projects.removeAll { $0.id == project.id }
        saveProjects()
    }

    func deleteProjects(at offsets: IndexSet) {
        projects.remove(atOffsets: offsets)
        saveProjects()
    }

    // MARK: - Row Counter Operations

    func incrementRow(for projectId: UUID, sectionId: UUID) {
        guard let projectIndex = projects.firstIndex(where: { $0.id == projectId }),
              let sectionIndex = projects[projectIndex].sections.firstIndex(where: { $0.id == sectionId }) else {
            return
        }

        let section = projects[projectIndex].sections[sectionIndex]
        if section.currentRow < section.totalRows {
            projects[projectIndex].sections[sectionIndex].currentRow += 1
            projects[projectIndex].updatedAt = Date()
            saveProjects()
        }
    }

    func decrementRow(for projectId: UUID, sectionId: UUID) {
        guard let projectIndex = projects.firstIndex(where: { $0.id == projectId }),
              let sectionIndex = projects[projectIndex].sections.firstIndex(where: { $0.id == sectionId }) else {
            return
        }

        if projects[projectIndex].sections[sectionIndex].currentRow > 0 {
            projects[projectIndex].sections[sectionIndex].currentRow -= 1
            projects[projectIndex].updatedAt = Date()
            saveProjects()
        }
    }

    // MARK: - Persistence

    private func saveProjects() {
        if let encoded = try? JSONEncoder().encode(projects) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }

    private func loadProjects() {
        if let savedData = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([KnittingProject].self, from: savedData) {
            projects = decoded
        }
    }

    // MARK: - Sample Data

    private func loadSampleData() {
        let cozySweater = KnittingProject(
            name: "Cozy Cable Sweater",
            description: "Winter Collection 2025",
            sections: [
                ProjectSection(
                    name: "Back",
                    currentRow: 15,
                    totalRows: 40,
                    patternInstructions: "Cast on 80 sts. Work K2, P2 ribbing for 2 inches, then stockinette stitch until piece measures 22 inches from cast on edge.",
                    stitchCount: 80
                ),
                ProjectSection(
                    name: "Front",
                    currentRow: 12,
                    totalRows: 40,
                    patternInstructions: "Work same as back until piece measures 20 inches. Begin neck shaping: bind off center 20 sts, then work each side separately.",
                    stitchCount: 80
                ),
                ProjectSection(
                    name: "Sleeves",
                    currentRow: 26,
                    totalRows: 40,
                    patternInstructions: "Row 26 (Cable Cross): K2, *slip 2 to cable needle and hold in front, K2, K2 from cable needle, P2* repeat to last 2 sts, K2",
                    stitchCount: 60
                ),
                ProjectSection(
                    name: "Merge & Yoke",
                    currentRow: 0,
                    totalRows: 20,
                    patternInstructions: "Join all pieces. Work in the round, decreasing evenly to shape yoke.",
                    stitchCount: 220
                )
            ],
            notes: "Using Cascade 220 yarn, color Heather. Size 8 needles."
        )

        let stripedScarf = KnittingProject(
            name: "Striped Scarf",
            description: "Gift for Mom",
            sections: [
                ProjectSection(
                    name: "Main Body",
                    currentRow: 85,
                    totalRows: 100,
                    patternInstructions: "Continue stripe pattern: *6 rows color A, 6 rows color B* repeat",
                    stitchCount: 40
                )
            ],
            notes: "Colors: Navy and Cream"
        )

        let babyBlanket = KnittingProject(
            name: "Baby Blanket",
            description: "For Sarah's shower",
            sections: [
                ProjectSection(
                    name: "Main Panel",
                    currentRow: 18,
                    totalRows: 100,
                    patternInstructions: "Garter stitch throughout. Work until square (approximately 30 inches).",
                    stitchCount: 120
                )
            ],
            notes: "Soft yellow yarn, washable"
        )

        projects = [cozySweater, stripedScarf, babyBlanket]
    }
}