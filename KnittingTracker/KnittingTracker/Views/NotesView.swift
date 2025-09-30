import SwiftUI

struct NotesView: View {
    @Environment(\.dismiss) var dismiss
    let project: KnittingProject
    @ObservedObject var store: ProjectStore

    @State private var notes: String

    init(project: KnittingProject, store: ProjectStore) {
        self.project = project
        self.store = store
        _notes = State(initialValue: project.notes)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    TextEditor(text: $notes)
                        .padding()
                        .scrollContentBackground(.hidden)
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(12)
                        .padding()
                }
            }
            .navigationTitle("Project Notes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveNotes()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func saveNotes() {
        var updatedProject = project
        updatedProject.notes = notes
        store.updateProject(updatedProject)
    }
}