import Foundation
import SwiftData

enum InspectionStatus: String, CaseIterable, Codable, Identifiable {
    case open
    case inProgress
    case resolved
    case closed
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .open: return "Open"
        case .inProgress: return "In Progress"
        case .resolved: return "Resolved"
        case .closed: return "Closed"
        }
    }
}

@Model
final class Inspection {
    @Attribute(.unique) var id: UUID
    var title: String
    var status: InspectionStatus
    var x_coord: Double
    var y_coord: Double
    var createdAt: Date
    
    var project: Project?
    @Relationship(deleteRule: .cascade, inverse: \Photo.inspection) var photos: [Photo]? = []
    
    init(title: String, status: InspectionStatus = .open, x: Double, y: Double) {
        self.id = UUID()
        self.title = title
        self.status = status
        self.x_coord = x
        self.y_coord = y
        self.createdAt = Date()
        self.photos = []
    }
}

@Model
final class Photo {
    @Attribute(.unique) var id: UUID
    var imageData: Data
    var timestamp: Date
    
    var inspection: Inspection?
    
    init(imageData: Data) {
        self.id = UUID()
        self.imageData = imageData
        self.timestamp = Date()
    }
}
