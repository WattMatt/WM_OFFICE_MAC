import Foundation
import SwiftData

@Model
final class CostReport {
    var id: UUID
    var title: String
    var dateCreated: Date
    var isFinalized: Bool
    
    @Relationship(deleteRule: .cascade)
    var categories: [CostCategory] = []
    
    init(title: String, dateCreated: Date = Date(), isFinalized: Bool = false) {
        self.id = UUID()
        self.title = title
        self.dateCreated = dateCreated
        self.isFinalized = isFinalized
    }
}
