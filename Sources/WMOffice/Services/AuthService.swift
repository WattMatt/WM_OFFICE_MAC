import Foundation
import Supabase
import SwiftUI

@Observable
class AuthService {
    static let shared = AuthService()
    
    // Replace these with actual project configuration or environment variables
    private let supabaseUrl = URL(string: "https://your-project.supabase.co")!
    private let supabaseKey = "your-anon-key"
    
    let client: SupabaseClient
    
    var session: Session?
    var user: User?
    var isAuthenticated: Bool = false
    
    private init() {
        self.client = SupabaseClient(supabaseURL: supabaseUrl, supabaseKey: supabaseKey)
        
        Task {
            await initializeSession()
        }
    }
    
    @MainActor
    func initializeSession() async {
        do {
            self.session = try await client.auth.session
            self.user = self.session?.user
            self.isAuthenticated = (self.session != nil)
        } catch {
            print("Session initialization failed: \(error)")
        }
        
        // Listen for auth state changes
        for await state in client.auth.authStateChanges {
            self.session = state.session
            self.user = state.session?.user
            self.isAuthenticated = (state.session != nil)
        }
    }
    
    @MainActor
    func signIn(email: String, password: String) async throws {
        _ = try await client.auth.signIn(email: email, password: password)
    }
    
    @MainActor
    func signOut() async throws {
        try await client.auth.signOut()
    }
    
    func currentUser() -> User? {
        return user
    }
}
