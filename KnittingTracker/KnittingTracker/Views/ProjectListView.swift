import SwiftUI

struct ProjectListView: View {
    @StateObject private var store = ProjectStore()
    @State private var showingNewProject = false
    @State private var searchText = ""

    var filteredProjects: [KnittingProject] {
        if searchText.isEmpty {
            return store.projects
        } else {
            return store.projects.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredProjects) { project in
                    NavigationLink(destination: ProjectDetailView(project: project, store: store)) {
                        ProjectRowView(project: project)
                    }
                }
                .onDelete(perform: store.deleteProjects)
            }
            .navigationTitle("My Projects")
            .searchable(text: $searchText, prompt: "Search projects")
            .toolbar(content: toolbarContent)
            .sheet(isPresented: $showingNewProject) {
                NewProjectView(store: store)
            }
            .overlay {
                if store.projects.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "scissors")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("No Projects Yet")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("Tap + to create your first knitting project")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    @ToolbarContentBuilder
    private func toolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: { showingNewProject = true }) {
                Image(systemName: "plus")
            }
        }
        ToolbarItem(placement: .topBarLeading) {
            EditButton()
        }
    }
}