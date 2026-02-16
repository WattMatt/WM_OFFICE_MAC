import SwiftUI
import SwiftData

struct HandoverChecklistView: View {
    @Bindable var project: Project
    @Environment(\.modelContext) private var modelContext
    
    @State private var showingAddItem = false
    @State private var newItemName = ""
    @State private var newItemRequired = true
    
    var body: some View {
        List {
            Section("Required Documents") {
                ForEach(project.handoverItems?.filter { $0.isRequired } ?? []) { item in
                    HandoverItemRow(item: item)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                deleteItem(item)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
            
            Section("Optional Documents") {
                ForEach(project.handoverItems?.filter { !$0.isRequired } ?? []) { item in
                    HandoverItemRow(item: item)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                deleteItem(item)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
        }
        .navigationTitle("Handover Checklist")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingAddItem = true }) {
                    Label("Add Item", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddItem) {
            NavigationStack {
                Form {
                    TextField("Document Name", text: $newItemName)
                    Toggle("Required", isOn: $newItemRequired)
                }
                .navigationTitle("New Item")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showingAddItem = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            addItem()
                            showingAddItem = false
                        }
                        .disabled(newItemName.isEmpty)
                    }
                }
            }
        }
    }

    private func addItem() {
        let newItem = HandoverItem(documentName: newItemName, isRequired: newItemRequired)
        if project.handoverItems == nil {
            project.handoverItems = []
        }
        project.handoverItems?.append(newItem)
        newItemName = ""
        newItemRequired = true
    }
    
    private func deleteItem(_ item: HandoverItem) {
        if let index = project.handoverItems?.firstIndex(where: { $0.id == item.id }) {
            project.handoverItems?.remove(at: index)
            modelContext.delete(item)
        }
    }
}

struct HandoverItemRow: View {
    @Bindable var item: HandoverItem
    
    var body: some View {
        HStack {
            Image(systemName: statusIcon)
                .foregroundColor(statusColor)
                .font(.title2)
            
            VStack(alignment: .leading) {
                Text(item.documentName)
                    .font(.headline)
                if let link = item.link, !link.isEmpty {
                    Link(destination: URL(string: link)!) {
                        Text(link)
                            .font(.caption)
                            .lineLimit(1)
                    }
                }
            }
            
            Spacer()
            
            Picker("Status", selection: $item.status) {
                ForEach(HandoverStatus.allCases, id: \.self) { status in
                    Text(status.rawValue).tag(status)
                }
            }
            .labelsHidden()
            .frame(width: 120)
        }
        .padding(.vertical, 4)
    }
    
    var statusIcon: String {
        switch item.status {
        case .uploaded: return "checkmark.circle.fill"
        case .missing: return "exclamationmark.circle.fill"
        case .pending: return "clock.fill"
        case .notApplicable: return "minus.circle.fill"
        }
    }
    
    var statusColor: Color {
        switch item.status {
        case .uploaded: return .green
        case .missing: return .red
        case .pending: return .orange
        case .notApplicable: return .gray
        }
    }
}
