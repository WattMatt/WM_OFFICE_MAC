import Foundation
import SwiftData

@Model
final class LineItem {
    var id: UUID
    var name: String
    var amount: Decimal
    var date: Date
    var notes: String?
    
    @Relationship(inverse: \CostCategory.lineItems)
    var category: CostCategory?
    
    init(name: String, amount: Decimal, date: Date = Date(), notes: String? = nil) {
        self.id = UUID()
        self.name = name
        self.amount = amount
        self.date = date
        self.notes = notes
    }
}
