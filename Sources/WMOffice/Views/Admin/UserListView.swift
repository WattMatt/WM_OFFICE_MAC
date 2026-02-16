import SwiftUI
import SwiftData

struct UserListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \AppUser.username) private var users: [AppUser]
    @State private var selection: AppUser.ID?
    @State private var showAddUserSheet = false
    
    var body: some View {
        Table(users, selection: $selection) {
            TableColumn("Username", value: \.username)
            TableColumn("Email", value: \.email)
            TableColumn("Role") { user in
                Picker("Role", selection: Binding(
                    get: { user.role },
                    set: { user.role = $0 }
                )) {
                    ForEach(UserRole.allCases) { role in
                        Text(role.displayName).tag(role)
                    }
                }
                .labelsHidden()
                .pickerStyle(.menu)
                .frame(width: 100)
            }
        }
        .navigationTitle("User Management")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showAddUserSheet = true }) {
                    Label("Add User", systemImage: "plus")
                }
            }
            ToolbarItem(placement: .destructiveAction) {
                Button(action: deleteSelectedUsers) {
                    Label("Delete", systemImage: "trash")
                }
                .disabled(selection == nil)
            }
        }
        .sheet(isPresented: $showAddUserSheet) {
            AddUserSheet()
        }
    }
    
    private func deleteSelectedUsers() {
        guard let selection else { return }
        if let user = users.first(where: { $0.id == selection }) {
            modelContext.delete(user)
        }
        self.selection = nil
    }
}

struct AddUserSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var username = ""
    @State private var email = ""
    @State private var role: UserRole = .user
    
    var body: some View {
        Form {
            TextField("Username", text: $username)
            TextField("Email", text: $email)
            Picker("Role", selection: $role) {
                ForEach(UserRole.allCases) { role in
                    Text(role.displayName).tag(role)
                }
            }
        }
        .padding()
        .frame(width: 300)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    let newUser = AppUser(username: username, email: email, role: role)
                    modelContext.insert(newUser)
                    dismiss()
                }
                .disabled(username.isEmpty || email.isEmpty)
            }
        }
    }
}
