import Foundation

enum ProjectStatus: String, CaseIterable, Identifiable {
    case active
    case pending
    case completed
    case archived
    
    var id: String { rawValue }
}

struct Project: Identifiable, Hashable {
    let id: UUID
    var name: String
    var status: ProjectStatus
}
