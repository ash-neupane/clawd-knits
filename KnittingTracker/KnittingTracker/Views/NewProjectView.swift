import SwiftUI

struct NewProjectView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var store: ProjectStore

    @State private var projectName = ""
    @State private var projectDescription = ""
    @State private var projectNotes = ""
    @State private var sections: [SectionInput] = [
        SectionInput(name: "Main Section", totalRows: 50)
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Project Details") {
                    TextField("Project Name", text: $projectName)
                    TextField("Description", text: $projectDescription)
                    TextField("Notes", text: $projectNotes, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Sections") {
                    ForEach($sections) { $section in
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("Section Name", text: $section.name)
                            Stepper("Total Rows: \(section.totalRows)", value: $section.totalRows, in: 1...500)
                        }
                    }
                    .onDelete(perform: deleteSection)

                    Button(action: addSection) {
                        Label("Add Section", systemImage: "plus.circle")
                    }
                }
            }
            .navigationTitle("New Project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        saveProject()
                    }
                    .disabled(projectName.isEmpty)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func addSection() {
        sections.append(SectionInput(name: "New Section", totalRows: 50))
    }

    private func deleteSection(at offsets: IndexSet) {
        guard sections.count > 1 else { return }
        sections.remove(atOffsets: offsets)
    }

    private func saveProject() {
        let newSections = sections.map { sectionInput in
            ProjectSection(
                name: sectionInput.name,
                totalRows: sectionInput.totalRows,
                patternInstructions: "Add your pattern instructions here",
                stitchCount: nil
            )
        }

        let project = KnittingProject(
            name: projectName,
            description: projectDescription,
            sections: newSections,
            notes: projectNotes
        )

        store.addProject(project)
        dismiss()
    }
}

// MARK: - Section Input Model

struct SectionInput: Identifiable {
    let id = UUID()
    var name: String
    var totalRows: Int
}