import SwiftUI
import SwiftData

struct StaffListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \StaffMember.name) private var staff: [StaffMember]
    @Binding var selection: StaffMember?
    @State private var showingAddSheet = false
    
    var body: some View {
        List(selection: $selection) {
            ForEach(staff) { member in
                NavigationLink(value: member) {
                    VStack(alignment: .leading) {
                        Text(member.name)
                            .font(.headline)
                        Text(member.role)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .onDelete(perform: deleteItems)
        }
        .navigationTitle("Staff")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingAddSheet = true }) {
                    Label("Add Staff", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddStaffView()
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(staff[index])
            }
        }
    }
}

struct StaffDetailView: View {
    @Bindable var staff: StaffMember
    
    var body: some View {
        Form {
            Section(header: Text("Details")) {
                TextField("Name", text: $staff.name)
                TextField("Role", text: $staff.role)
                TextField("Email", text: $staff.email)
                TextField("Phone", text: $staff.phone)
            }
        }
        .navigationTitle(staff.name)
    }
}

struct AddStaffView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var role = ""
    @State private var email = ""
    @State private var phone = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                    TextField("Role", text: $role)
                    TextField("Email", text: $email)
                    TextField("Phone", text: $phone)
                }
            }
            .navigationTitle("Add Staff")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newItem = StaffMember(name: name, role: role, email: email, phone: phone)
                        modelContext.insert(newItem)
                        dismiss()
                    }
                    .disabled(name.isEmpty || role.isEmpty)
                }
            }
        }
    }
}
