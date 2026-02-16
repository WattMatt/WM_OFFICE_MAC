import Foundation
import SwiftData

enum HandoverStatus: String, Codable, CaseIterable {
    case missing = "Missing"
    case uploaded = "Uploaded"
    case pending = "Pending"
    case notApplicable = "N/A"
}

@Model
final class HandoverItem {
    @Attribute(.unique) var id: UUID
    var documentName: String
    var isRequired: Bool
    var status: HandoverStatus
    var link: String?
    var project: Project?
    
    init(documentName: String, isRequired: Bool = true, status: HandoverStatus = .missing, link: String? = nil) {
        self.id = UUID()
        self.documentName = documentName
        self.isRequired = isRequired
        self.status = status
        self.link = link
    }
}
