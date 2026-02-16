import Foundation
import SwiftData

enum MarkupType: String, CaseIterable, Codable, Identifiable {
    case inspection
    case note
    case measurement
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .inspection: return "Inspection"
        case .note: return "Note"
        case .measurement: return "Measurement"
        }
    }
}

@Model
final class Markup {
    @Attribute(.unique) var id: UUID
    var type: MarkupType
    var title: String
    var content: String
    var x: Double
    var y: Double
    var createdAt: Date
    
    // For specific types
    var status: String? // For inspection status
    var colorHex: String? // For visual customization
    
    var drawing: Drawing?
    
    init(type: MarkupType = .note, title: String, content: String = "", x: Double, y: Double, drawing: Drawing? = nil) {
        self.id = UUID()
        self.type = type
        self.title = title
        self.content = content
        self.x = x
        self.y = y
        self.createdAt = Date()
        self.drawing = drawing
    }
}
