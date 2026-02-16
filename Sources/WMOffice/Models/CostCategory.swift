import Foundation
import SwiftData

@Model
final class CostCategory {
    var id: UUID
    var name: String
    var budget: Decimal?
    
    @Relationship(inverse: \CostReport.categories)
    var report: CostReport?
    
    @Relationship(deleteRule: .cascade)
    var lineItems: [LineItem] = []
    
    init(name: String, budget: Decimal? = nil) {
        self.id = UUID()
        self.name = name
        self.budget = budget
    }
    
    var totalActual: Decimal {
        lineItems.reduce(0) { $0 + $1.amount }
    }
}
