import Foundation
import SwiftData

@Model
final class AppUser {
    var username: String
    var email: String
    var role: UserRole
    var createdAt: Date
    
    init(username: String, email: String, role: UserRole = .user) {
        self.username = username
        self.email = email
        self.role = role
        self.createdAt = Date()
    }
}

enum UserRole: String, Codable, CaseIterable, Identifiable {
    case admin
    case user
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .admin: return "Admin"
        case .user: return "User"
        }
    }
}
