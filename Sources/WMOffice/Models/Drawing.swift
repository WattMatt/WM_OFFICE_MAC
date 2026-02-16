import Foundation
import SwiftData

enum DrawingStatus: String, CaseIterable, Codable, Identifiable {
    case draft
    case approved
    case superseded
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .draft: return "Draft"
        case .approved: return "Approved"
        case .superseded: return "Superseded"
        }
    }
}

@Model
final class Drawing {
    @Attribute(.unique) var id: UUID
    var drawingNumber: String
    var title: String
    var revision: String
    var status: DrawingStatus
    var uploadedDate: Date
    @Attribute(.externalStorage) var imageData: Data?
    
    var project: Project?
    
    @Relationship(deleteRule: .cascade) var markups: [Markup]? = []
    
    init(drawingNumber: String, title: String, revision: String, status: DrawingStatus = .draft, project: Project? = nil) {
        self.id = UUID()
        self.drawingNumber = drawingNumber
        self.title = title
        self.revision = revision
        self.status = status
        self.uploadedDate = Date()
        self.project = project
    }
}
