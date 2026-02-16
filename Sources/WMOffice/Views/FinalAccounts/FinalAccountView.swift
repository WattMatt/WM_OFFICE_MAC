import SwiftUI
import SwiftData

struct FinalAccountListView: View {
    @Binding var selection: FinalAccount?
    @Query private var finalAccounts: [FinalAccount]
    
    @State private var showingAddSheet = false
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        List(finalAccounts, selection: $selection) { item in
            NavigationLink(value: item) {
                VStack(alignment: .leading) {
                    Text(item.boqItem)
                        .font(.headline)
                    Text("Variance: \(item.variance, format: .currency(code: "GBP"))")
                        .font(.caption)
                        .foregroundStyle(item.variance >= 0 ? .green : .red)
                }
            }
        }
        .navigationTitle("Final Accounts")
        .toolbar {
            Button(action: { showingAddSheet = true }) {
                Label("Add Item", systemImage: "plus")
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddFinalAccountView()
        }
    }
}

struct FinalAccountDetailView: View {
    let account: FinalAccount
    
    var body: some View {
        Form {
            Section("Details") {
                LabeledContent("BOQ Item", value: account.boqItem)
                LabeledContent("Original Qty", value: account.originalQty, format: .number)
                LabeledContent("Final Qty", value: account.finalQty, format: .number)
                LabeledContent("Rate", value: account.rate, format: .currency(code: "GBP"))
            }
            
            Section("Analysis") {
                LabeledContent("Variance", value: account.variance, format: .currency(code: "GBP"))
                    .foregroundStyle(account.variance >= 0 ? .green : .red)
            }
        }
        .navigationTitle(account.boqItem)
    }
}

// Reusing the Add view from before but making sure it's available
struct AddFinalAccountView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var boqItem = ""
    @State private var originalQty = 0.0
    @State private var finalQty = 0.0
    @State private var rate = 0.0
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("BOQ Item", text: $boqItem)
                
                TextField("Original Qty", value: $originalQty, format: .number)
                TextField("Final Qty", value: $finalQty, format: .number)
                TextField("Rate", value: $rate, format: .currency(code: "GBP"))
            }
            .navigationTitle("Add Final Account Item")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newItem = FinalAccount(
                            boqItem: boqItem,
                            originalQty: originalQty,
                            finalQty: finalQty,
                            rate: rate
                        )
                        modelContext.insert(newItem)
                        dismiss()
                    }
                }
            }
            .padding()
        }
    }
}
