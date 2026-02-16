import SwiftUI
import SwiftData

struct CostReportDetailView: View {
    @Bindable var report: CostReport
    @Environment(\.modelContext) private var modelContext
    
    @State private var showingAddCategory = false
    @State private var newCategoryName = ""
    
    var body: some View {
        List {
            Section(header: Text("Summary")) {
                LabeledContent("Status", value: report.isFinalized ? "Finalized" : "Draft")
                LabeledContent("Date", value: report.dateCreated, format: .dateTime)
            }
            
            ForEach(report.categories) { category in
                Section(header: Text(category.name)) {
                    ForEach(category.lineItems) { item in
                        HStack {
                            Text(item.name)
                            Spacer()
                            Text(item.amount, format: .currency(code: "USD"))
                        }
                    }
                    
                    HStack {
                        Text("Total")
                            .bold()
                        Spacer()
                        Text(category.totalActual, format: .currency(code: "USD"))
                            .bold()
                    }
                }
            }
        }
        .navigationTitle(report.title)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Add Category", systemImage: "folder.badge.plus") {
                    showingAddCategory = true
                }
            }
        }
        .alert("New Category", isPresented: $showingAddCategory) {
            TextField("Name", text: $newCategoryName)
            Button("Cancel", role: .cancel) { }
            Button("Add") {
                addCategory()
            }
        }
    }
    
    private func addCategory() {
        let category = CostCategory(name: newCategoryName)
        report.categories.append(category)
        newCategoryName = ""
    }
}
