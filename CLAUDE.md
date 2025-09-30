# Knitting Tracker iOS Application - Complete Source Code

**SwiftUI iOS Application for Managing Knitting Projects**

## Overview

This is a complete iOS application built with SwiftUI that allows knitters to track their projects with multiple sections, row counters, pattern instructions, and progress visualization.

### Features
- ✅ Project list with search and filtering
- ✅ Multi-section project management (Back, Front, Sleeves, etc.)
- ✅ Row counter with increment/decrement controls
- ✅ Pattern diagram visualization
- ✅ Progress tracking (per-section and overall)
- ✅ Data persistence using UserDefaults
- ✅ Notes and pattern instructions per section
- ✅ Tab navigation between sections
- ✅ Add/Edit/Delete projects and sections

### Tech Stack
- **Language**: Swift 5.9+
- **Framework**: SwiftUI
- **Architecture**: MVVM (Model-View-ViewModel)
- **Persistence**: UserDefaults (JSON encoding)
- **Minimum iOS**: 16.0+

### Project Structure
```
KnittingTracker/
├── KnittingTrackerApp.swift          # Main app entry point
├── Models/
│   └── KnittingModels.swift          # Data models (Project, Section, etc.)
├── ViewModels/
│   └── ProjectStore.swift            # State management & persistence
├── Views/
│   ├── ProjectListView.swift         # Main project list screen
│   ├── ProjectDetailView.swift       # Project detail with sections
│   ├── NewProjectView.swift          # Create new project form
│   ├── PatternDiagramView.swift      # Pattern visualization
│   └── Components/
│       ├── ProjectRowView.swift      # List row component
│       ├── SectionProgressCard.swift # Section progress UI
│       └── RowCounterCard.swift      # Row counter UI component
```

---

## File: KnittingTrackerApp.swift

**Purpose**: Main application entry point that launches the app with SwiftUI App protocol.

```swift
import SwiftUI

@main
struct KnittingTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ProjectListView()
        }
    }
}
```

---

## File: Models/KnittingModels.swift

**Purpose**: Core data models for the application. Defines the structure of knitting projects, sections, and stitch symbols.

**Key Models**:
- `KnittingProject`: Main project model with sections, progress, and metadata
- `ProjectSection`: Individual section (e.g., "Sleeves") with row tracking
- `StitchSymbol`: Enum for common knitting symbols

```swift
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
```

---

## File: ViewModels/ProjectStore.swift

**Purpose**: Observable state manager that handles all project data operations including CRUD operations, persistence, and row counter updates.

**Key Responsibilities**:
- Manage array of projects
- Handle data persistence with UserDefaults
- Provide methods for add/update/delete operations
- Row counter increment/decrement logic

```swift
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
```

---

## File: Views/ProjectListView.swift

**Purpose**: Main screen showing list of all knitting projects with search functionality.

**Features**:
- Display all projects in a scrollable list
- Search/filter projects by name or description
- Navigate to project details
- Create new projects
- Delete projects with swipe

```swift
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingNewProject = true }) {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
            }
            .sheet(isPresented: $showingNewProject) {
                NewProjectView(store: store)
            }
            .overlay {
                if store.projects.isEmpty {
                    ContentUnavailableView(
                        "No Projects Yet",
                        systemImage: "scissors",
                        description: Text("Tap + to create your first knitting project")
                    )
                }
            }
        }
    }
}
```

---

## File: Views/Components/ProjectRowView.swift

**Purpose**: Reusable row component for displaying project summary in the list.

**Displays**:
- Project name and description
- Overall progress percentage
- Progress bar
- Last updated time

```swift
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
```

---

## File: Views/ProjectDetailView.swift

**Purpose**: Main project detail screen showing sections, row counter, and pattern instructions.

**Features**:
- Overall project progress header
- Tab navigation between sections
- Section-specific progress card
- Interactive row counter
- Pattern diagram visualization
- Pattern instructions display
- Action buttons (Help, Notes)

```swift
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
                VStack(spacing: 16) {
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
            }
        }
        .navigationBarTitleDisplayMode(.inline)
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
                .background(Color.white)
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
```

---

## File: Views/Components/SectionProgressCard.swift

**Purpose**: Displays progress for the current section.

```swift
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
```

---

## File: Views/Components/RowCounterCard.swift

**Purpose**: Interactive row counter with increment/decrement buttons.

```swift
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
```

---

# Knitting Tracker - Part 2: Remaining Modules

## File: Views/PatternDiagramView.swift

**Purpose**: Visual representation of knitting pattern chart with current row highlighted.

**Features**:
- Grid-based pattern display
- Row numbers on the left
- Current row highlighting
- Stitch symbols rendered with Canvas

```swift
import SwiftUI

struct PatternDiagramView: View {
    let currentRow: Int
    
    var body: some View {
        Canvas { context, size in
            let gridSize: CGFloat = 20
            let rows = 8
            let cols = Int(size.width / gridSize)
            
            // Draw grid
            for row in 0.. 1 else { return } // Keep at least one section
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
```

---

## File: Views/NotesView.swift

**Purpose**: Modal view for viewing and editing project notes.

**Features**:
- Full-screen text editor
- Save and cancel buttons
- Auto-focus on notes field

```swift
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
    }
    
    private func saveNotes() {
        var updatedProject = project
        updatedProject.notes = notes
        store.updateProject(updatedProject)
    }
}
```

---

## Setup Instructions

### 1. Create New Xcode Project

1. **Open Xcode** (version 15.0 or later)
2. **File → New → Project**
3. Choose **iOS** → **App**
4. Configure project:
   - **Product Name**: `KnittingTracker`
   - **Team**: Your team (or None)
   - **Organization Identifier**: `com.yourname`
   - **Interface**: **SwiftUI**
   - **Language**: **Swift**
   - **Storage**: None (we're using UserDefaults)
   - **Include Tests**: Optional
5. Click **Next** and choose save location

### 2. Set Deployment Target

1. Select project in navigator
2. Select target "KnittingTracker"
3. General tab → Minimum Deployments → **iOS 16.0**

### 3. Create Folder Structure

In Xcode Project Navigator:

1. Right-click on "KnittingTracker" folder
2. **New Group** → Name it "Models"
3. **New Group** → Name it "ViewModels"
4. **New Group** → Name it "Views"
5. Right-click on "Views" → **New Group** → Name it "Components"

Your structure should look like:
```
KnittingTracker/
├── KnittingTrackerApp.swift (already exists)
├── Models/
├── ViewModels/
└── Views/
    └── Components/
```

### 4. Add Swift Files

For each file mentioned in this documentation:

1. Right-click on appropriate folder
2. **New File** → **Swift File**
3. Name it exactly as shown (e.g., "KnittingModels.swift")
4. Copy-paste the code from the documentation
5. **Cmd+S** to save

**Files to create**:
- `Models/KnittingModels.swift`
- `ViewModels/ProjectStore.swift`
- `Views/ProjectListView.swift`
- `Views/ProjectDetailView.swift`
- `Views/NewProjectView.swift`
- `Views/NotesView.swift`
- `Views/PatternDiagramView.swift`
- `Views/Components/ProjectRowView.swift`
- `Views/Components/SectionProgressCard.swift`
- `Views/Components/RowCounterCard.swift`

### 5. Update KnittingTrackerApp.swift

Replace the content of the auto-generated file with:

```swift
import SwiftUI

@main
struct KnittingTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ProjectListView()
        }
    }
}
```

### 6. Build and Run

1. Select a simulator: **Product → Destination → iPhone 15 Pro**
2. **Cmd+R** or click the Play button
3. Wait for build to complete
4. App should launch with 3 sample projects

### 7. Troubleshooting Common Issues

**Issue: "Cannot find type 'ProjectStore' in scope"**
- Solution: Make sure ProjectStore.swift is in the project
- Clean build folder: **Product → Clean Build Folder** (Shift+Cmd+K)

**Issue: "Missing preview"**
- Solution: Add `#Preview` macro to any view for testing:
```swift
#Preview {
    ProjectListView()
}
```

**Issue: Build errors about iOS version**
- Solution: Check deployment target is iOS 16.0+
- Some SwiftUI features require iOS 16+

---

## Testing the App

### Test Scenario 1: View Projects
1. Launch app
2. See list of 3 sample projects
3. Observe progress percentages and bars
4. Tap "Cozy Cable Sweater"

### Test Scenario 2: Row Counter
1. In project detail view, tap **Sleeves** tab
2. Current row should be 26
3. Tap **+** button → row increments to 27
4. Tap **-** button → row decrements to 26
5. Go back and return → state persists

### Test Scenario 3: Create Project
1. Tap **+** in top right
2. Enter "Test Scarf" as name
3. Enter "Winter project" as description
4. Modify sections or add new ones
5. Tap **Create Project**
6. Verify new project appears in list

### Test Scenario 4: Delete Project
1. Swipe left on any project
2. Tap **Delete**
3. Project removed from list
4. Close and reopen app → deletion persists

### Test Scenario 5: Search
1. Pull down on project list to reveal search
2. Type "scarf"
3. Only matching projects appear
4. Clear search to see all projects

### Test Scenario 6: Notes
1. Open any project
2. Tap **Notes** button
3. Add or edit notes
4. Tap **Save**
5. Reopen notes → text persists

---

## Architecture Deep Dive

### Data Flow Diagram

```
User Action (tap +)
    ↓
View (RowCounterCard)
    ↓
Calls store.incrementRow(projectId, sectionId)
    ↓
ProjectStore (ViewModel)
    ↓
Updates projects array
    ↓
Triggers @Published
    ↓
JSON encode → UserDefaults
    ↓
View re-renders (SwiftUI automatic)
```

### State Management

**ObservableObject Pattern**:
- `ProjectStore` is `@MainActor` (runs on main thread)
- Uses `@Published` for reactive updates
- Views observe with `@ObservedObject` or `@StateObject`

**StateObject vs ObservedObject**:
- `@StateObject`: View **owns** the object (ProjectListView)
- `@ObservedObject`: View **observes** existing object (ProjectDetailView)

### Persistence Strategy

**Why UserDefaults?**
- Simple for MVP/prototype
- Automatic encoding with Codable
- Instant read/write
- No external dependencies

**Limitations**:
- Size limit (~4MB recommended)
- Not optimized for large datasets
- No relational queries
- No sync across devices

**Future Migration to CoreData/SwiftData**:
1. Create entity schema matching models
2. Replace UserDefaults save/load with Core Data context
3. Keep same view models and views
4. Minimal changes to business logic

---

## Customization Guide

### Change Color Scheme

In any view file, modify colors:

```swift
// Change primary blue to purple
.tint(.purple)
.foregroundColor(.purple)

// Change progress colors in ProjectRowView
private var progressColor: Color {
    switch project.overallProgress {
    case 0..<25: return .purple      // was .red
    case 25..<50: return .pink       // was .orange
    case 50..<75: return .indigo     // was .blue
    case 75..<100: return .mint      // was .green
    default: return .mint
    }
}
```

### Add Custom Stitch Symbols

In `KnittingModels.swift`, extend the enum:

```swift
enum StitchSymbol: String, CaseIterable {
    // ... existing cases ...
    case makeOne = "M1"
    case bobble = "◉"
    case twist = "⟲"
    
    var description: String {
        switch self {
        // ... existing cases ...
        case .makeOne: return "Make 1 (increase)"
        case .bobble: return "Bobble stitch"
        case .twist: return "Twist stitch"
        }
    }
    
    var systemImage: String {
        switch self {
        // ... existing cases ...
        case .makeOne: return "arrow.up"
        case .bobble: return "circle.hexagongrid.fill"
        case .twist: return "arrow.clockwise"
        }
    }
}
```

### Add Haptic Feedback

Add to `RowCounterCard.swift`:

```swift
import UIKit

struct RowCounterCard: View {
    // ... existing code ...
    
    private func incrementRow() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        onIncrement()
    }
    
    private func decrementRow() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        onDecrement()
    }
}
```

### Add Completion Celebration

In `ProjectDetailView.swift`:

```swift
@State private var showCompletionAlert = false

// In body, after .navigationBarTitleDisplayMode
.alert("Section Complete! 🎉", isPresented: $showCompletionAlert) {
    Button("Continue") { }
    Button("Next Section") {
        if selectedSectionIndex < project.sections.count - 1 {
            selectedSectionIndex += 1
        }
    }
} message: {
    Text("You've finished \(currentSection.name)!")
}

// Modify incrementRow
private func incrementRow() {
    store.incrementRow(for: project.id, sectionId: currentSection.id)
    
    // Check if section just completed
    if currentSection.currentRow + 1 == currentSection.totalRows {
        showCompletionAlert = true
    }
}
```

---

## Performance Optimization

### Lazy Loading (for large project lists)

```swift
// In ProjectListView
ScrollView {
    LazyVStack {
        ForEach(filteredProjects) { project in
            NavigationLink(destination: ProjectDetailView(project: project, store: store)) {
                ProjectRowView(project: project)
            }
        }
    }
}
```

### Debounced Search

```swift
import Combine

struct ProjectListView: View {
    @State private var searchText = ""
    @State private var debouncedSearchText = ""
    
    var body: some View {
        // ... existing code ...
        .searchable(text: $searchText)
        .onChange(of: searchText) { oldValue, newValue in
            // Debounce search by 300ms
            Task {
                try? await Task.sleep(nanoseconds: 300_000_000)
                if searchText == newValue {
                    debouncedSearchText = newValue
                }
            }
        }
    }
    
    var filteredProjects: [KnittingProject] {
        if debouncedSearchText.isEmpty {
            return store.projects
        } else {
            return store.projects.filter {
                $0.name.localizedCaseInsensitiveContains(debouncedSearchText)
            }
        }
    }
}
```

---

## Future Enhancements Roadmap

### Phase 1: Core Features (2-4 weeks)
- ✅ Project list and detail views
- ✅ Row counter
- ✅ Pattern instructions
- ✅ Basic persistence
- ⏳ Image upload for patterns
- ⏳ PDF pattern viewer
- ⏳ Enhanced pattern diagram with zoom

### Phase 2: Advanced Features (1-2 months)
- ⏳ CoreData/SwiftData migration
- ⏳ iCloud sync
- ⏳ Multiple counters (row, repeat, stitch)
- ⏳ Timer for timed patterns
- ⏳ Voice notes recording
- ⏳ Progress photos gallery
- ⏳ Export to PDF report

### Phase 3: Community Features (2-3 months)
- ⏳ Pattern sharing
- ⏳ Social features (share progress)
- ⏳ Pattern marketplace integration
- ⏳ Yarn database with search
- ⏳ Needle size calculator
- ⏳ Gauge calculator

### Phase 4: Pro Features (3+ months)
- ⏳ Apple Watch app (quick counter access)
- ⏳ Widget for home screen
- ⏳ Live Activities for row tracking
- ⏳ Siri shortcuts
- ⏳ Apple Pencil support for pattern markup
- ⏳ AR try-on (Vision Pro)
- ⏳ Collaboration (multiple users per project)

---

## Code Quality & Best Practices

### SwiftUI Best Practices Used

1. **Single Responsibility**: Each view has one clear purpose
2. **Composition**: Small, reusable components
3. **MVVM**: Clear separation of concerns
4. **Declarative UI**: State-driven, not imperative
5. **Type Safety**: Strong typing with enums and structs

### Code Organization

```swift
// MARK: comments for organization
// MARK: - Header Section
// MARK: - Row Counter Operations

// Group related code
private var headerSection: some View { }
private var sectionTabs: some View { }

// Extract complex logic
private func timeAgo(_ date: Date) -> String { }
```

### Error Handling

Add error handling to persistence:

```swift
private func saveProjects() {
    do {
        let encoded = try JSONEncoder().encode(projects)
        UserDefaults.standard.set(encoded, forKey: saveKey)
    } catch {
        print("Failed to save projects: \(error.localizedDescription)")
        // TODO: Show error alert to user
    }
}
```

---
  
