import SwiftUI
import SwiftData

struct ProjectListView: View {
    @Binding var selection: Project?
    @Query(sort: \Project.title) private var projects: [Project]
    @Environment(\.modelContext) private var modelContext
    
    @State private var showingAddSheet = false
    @State private var projectToEdit: Project?
    
    var body: some View {
        List(selection: $selection) {
            ForEach(projects) { project in
                NavigationLink(value: project) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(project.title)
                                .font(.headline)
                            Text(project.status.title)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if let lastSync = project.lastSync {
                            Text(lastSync, style: .date)
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        deleteProject(project)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    
                    Button {
                        projectToEdit = project
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    .tint(.blue)
                }
            }
        }
        .navigationTitle("Projects")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingAddSheet = true }) {
                    Label("Add Project", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            ProjectEditView(project: nil)
        }
        .sheet(item: $projectToEdit) { project in
            ProjectEditView(project: project)
        }
    }
    
    private func deleteProject(_ project: Project) {
        let projectId = project.id
        modelContext.delete(project)
        
        // Sync Integration
        Task {
            await SyncQueue.shared.enqueue {
                // Mock network call
                print("Syncing delete for project \(projectId)")
                try await Task.sleep(nanoseconds: 500_000_000)
            }
        }
    }
}

struct ProjectEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var title: String
    @State private var status: ProjectStatus
    @State private var budget: Double
    
    let project: Project?
    
    init(project: Project?) {
        self.project = project
        _title = State(initialValue: project?.title ?? "")
        _status = State(initialValue: project?.status ?? .pending)
        _budget = State(initialValue: project?.budget ?? 0.0)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
                Picker("Status", selection: $status) {
                    ForEach(ProjectStatus.allCases) { status in
                        Text(status.title).tag(status)
                    }
                }
                TextField("Budget", value: $budget, format: .currency(code: "USD"))
                    .keyboardType(.decimalPad)
            }
            .navigationTitle(project == nil ? "New Project" : "Edit Project")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func save() {
        if let project = project {
            project.title = title
            project.status = status
            project.budget = budget
            project.lastSync = Date() // Mark as needing sync or just updated locally
            
            // Sync Update
            let projectId = project.id
            let projectTitle = title
            Task {
                await SyncQueue.shared.enqueue {
                    print("Syncing update for project \(projectId): \(projectTitle)")
                    try await Task.sleep(nanoseconds: 500_000_000)
                }
            }
        } else {
            let newProject = Project(title: title, status: status, budget: budget)
            modelContext.insert(newProject)
            
            // Sync Create
            let projectId = newProject.id
            let projectTitle = title
            Task {
                await SyncQueue.shared.enqueue {
                    print("Syncing create for project \(projectId): \(projectTitle)")
                    try await Task.sleep(nanoseconds: 500_000_000)
                }
            }
        }
    }
}
