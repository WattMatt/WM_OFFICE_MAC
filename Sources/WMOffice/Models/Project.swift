import Foundation
import SwiftData

enum ProjectStatus: String, CaseIterable, Codable, Identifiable {
    case active
    case pending
    case completed
    case archived
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .active: return "Active"
        case .pending: return "Pending"
        case .completed: return "Completed"
        case .archived: return "Archived"
        }
    }
}

@Model
final class Project {
    @Attribute(.unique) var id: UUID
    var title: String
    var status: ProjectStatus
    var budget: Double
    var lastSync: Date?
    @Attribute(.externalStorage) var floorPlanImageData: Data?
    
    @Relationship(deleteRule: .cascade) var calculations: [CableCalculation]? = []
    @Relationship(deleteRule: .cascade) var inspections: [Inspection]? = []
    @Relationship(deleteRule: .cascade) var drawings: [Drawing]? = []
    @Relationship(deleteRule: .cascade) var handoverItems: [HandoverItem]? = []
    
    init(title: String, status: ProjectStatus = .pending, budget: Double = 0.0) {
        self.id = UUID()
        self.title = title
        self.status = status
        self.budget = budget
        self.lastSync = nil
    }
}
