import Foundation
import SwiftData

@Model
final class Invoice {
    var invoiceNumber: String
    var date: Date
    var amount: Decimal
    var status: InvoiceStatus
    
    // Relationship to Project (optional but likely needed in future, keeping simple for now)
    
    init(invoiceNumber: String, date: Date = Date(), amount: Decimal = 0.0, status: InvoiceStatus = .draft) {
        self.invoiceNumber = invoiceNumber
        self.date = date
        self.amount = amount
        self.status = status
    }
}

enum InvoiceStatus: String, Codable, CaseIterable, Identifiable {
    case draft
    case sent
    case paid
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .draft: return "Draft"
        case .sent: return "Sent"
        case .paid: return "Paid"
        }
    }
}
