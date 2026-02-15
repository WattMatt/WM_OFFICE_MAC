import Foundation

class ProjectService: ObservableObject {
    @Published var projects: [Project] = []
    
    init() {
        // Seed mock data
        self.projects = [
            Project(id: UUID(), name: "Website Redesign", status: .active),
            Project(id: UUID(), name: "Q1 Marketing Campaign", status: .pending),
            Project(id: UUID(), name: "Office Renovation", status: .completed),
            Project(id: UUID(), name: "Legacy System Migration", status: .archived)
        ]
    }
    
    func addProject(name: String) {
        let newProject = Project(id: UUID(), name: name, status: .pending)
        projects.append(newProject)
    }
}
