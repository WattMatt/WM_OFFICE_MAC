import Foundation
import SwiftData

@Model
final class StaffMember {
    var name: String
    var role: String
    var email: String
    var phone: String
    var dateAdded: Date
    
    init(name: String, role: String, email: String, phone: String) {
        self.name = name
        self.role = role
        self.email = email
        self.phone = phone
        self.dateAdded = Date()
    }
}
