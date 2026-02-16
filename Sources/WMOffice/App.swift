import SwiftUI
import SwiftData

@main
struct WMOfficeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            Project.self,
            SiteDiaryEntry.self,
            CostReport.self,
            CostCategory.self,
            LineItem.self,
            Material.self,
            ProcurementItem.self
        ])
    }
}

struct ContentView: View {
    @State private var authService = AuthService.shared

    var body: some View {
        Group {
            if authService.isAuthenticated {
                DashboardView()
            } else {
                LoginView()
            }
        }
    }
}
