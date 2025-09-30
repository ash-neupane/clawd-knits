import SwiftUI

struct ProjectDetailView: View {
    let project: KnittingProject
    @ObservedObject var store: ProjectStore
    @State private var selectedSectionIndex = 0
    @State private var showingNotes = false

    var body: some View {
        VStack(spacing: 0) {
            headerSection
            sectionTabs

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    SectionProgressCard(section: currentSection)
                    RowCounterCard(
                        section: currentSection,
                        onIncrement: { incrementRow() },
                        onDecrement: { decrementRow() }
                    )
                    patternInstructionsCard
                    patternDiagramCard
                    actionButtons
                }
                .padding()
                .padding(.bottom, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showingNotes) {
            NotesView(project: project, store: store)
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 8) {
            HStack {
                Text(project.name)
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }

            HStack {
                Text("Overall Progress")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(Int(project.overallProgress))%")
                    .font(.caption)
                    .fontWeight(.semibold)
            }

            ProgressView(value: project.overallProgress, total: 100)
                .tint(.blue)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
    }

    // MARK: - Section Tabs

    private var sectionTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(Array(project.sections.enumerated()), id: \.element.id) { index, section in
                    Button(action: {
                        withAnimation {
                            selectedSectionIndex = index
                        }
                    }) {
                        VStack(spacing: 4) {
                            Text(section.name)
                                .font(.caption)
                                .fontWeight(selectedSectionIndex == index ? .semibold : .regular)

                            Rectangle()
                                .fill(selectedSectionIndex == index ? Color.blue : Color.clear)
                                .frame(height: 2)
                        }
                        .frame(minWidth: 80)
                    }
                    .foregroundColor(selectedSectionIndex == index ? .primary : .secondary)
                }
            }
            .padding(.horizontal)
        }
        .frame(height: 44)
        .background(Color(UIColor.systemBackground))
        .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
    }

    private var currentSection: ProjectSection {
        project.sections[selectedSectionIndex]
    }

    // MARK: - Pattern Instructions Card

    private var patternInstructionsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Pattern Instructions")
                    .font(.headline)
                Spacer()
                if let stitchCount = currentSection.stitchCount {
                    Text("\(stitchCount) sts")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(6)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Row \(currentSection.currentRow)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)

                Text(currentSection.patternInstructions)
                    .font(.body)
                    .foregroundColor(.primary)
            }
            .padding()
            .background(Color(UIColor.tertiarySystemBackground))
            .cornerRadius(8)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }

    // MARK: - Pattern Diagram Card

    private var patternDiagramCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pattern Chart")
                .font(.headline)

            PatternDiagramView(currentRow: currentSection.currentRow)
                .frame(height: 200)
                .background(Color(UIColor.systemBackground))
                .cornerRadius(8)
                .shadow(color: .black.opacity(0.05), radius: 2)

            StitchLegendView()
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button(action: { showingNotes = true }) {
                Label("Notes", systemImage: "note.text")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            Button(action: { }) {
                Label("Help", systemImage: "questionmark.circle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
    }

    // MARK: - Row Counter Actions

    private func incrementRow() {
        store.incrementRow(for: project.id, sectionId: currentSection.id)
    }

    private func decrementRow() {
        store.decrementRow(for: project.id, sectionId: currentSection.id)
    }
}

// MARK: - Stitch Legend View

struct StitchLegendView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Legend")
                .font(.caption)
                .fontWeight(.semibold)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(StitchSymbol.allCases, id: \.self) { symbol in
                    HStack(spacing: 6) {
                        Image(systemName: symbol.systemImage)
                            .font(.caption2)
                            .frame(width: 16)
                        Text(symbol.description)
                            .font(.caption2)
                        Spacer()
                    }
                }
            }
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(8)
    }
}