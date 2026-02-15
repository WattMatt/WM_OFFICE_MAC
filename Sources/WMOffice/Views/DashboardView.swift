import SwiftUI

struct DashboardView: View {
    @StateObject private var service = ProjectService()
    @State private var selectedProject: Project.ID?

    var body: some View {
        NavigationSplitView {
            List(service.projects, selection: $selectedProject) { project in
                NavigationLink(value: project.id) {
                    HStack {
                        Image(systemName: icon(for: project.status))
                            .foregroundColor(color(for: project.status))
                        Text(project.name)
                        Spacer()
                        Text(project.status.rawValue.capitalized)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Projects")
        } detail: {
            if let projectId = selectedProject, 
               let project = service.projects.first(where: { $0.id == projectId }) {
                VStack(spacing: 20) {
                    Text(project.name)
                        .font(.largeTitle)
                    
                    Text("Status: \(project.status.rawValue.capitalized)")
                        .font(.headline)
                        .padding()
                        .background(color(for: project.status).opacity(0.1))
                        .cornerRadius(8)
                    
                    Spacer()
                }
                .padding()
            } else {
                Text("Select a project")
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private func icon(for status: ProjectStatus) -> String {
        switch status {
        case .active: return "play.circle.fill"
        case .pending: return "clock.fill"
        case .completed: return "checkmark.circle.fill"
        case .archived: return "archivebox.fill"
        }
    }
    
    private func color(for status: ProjectStatus) -> Color {
        switch status {
        case .active: return .green
        case .pending: return .orange
        case .completed: return .blue
        case .archived: return .gray
        }
    }
}
