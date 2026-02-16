import SwiftUI
import SwiftData

struct InvoiceDetailView: View {
    @Bindable var invoice: Invoice
    @Environment(\.dismiss) private var dismiss
    
    // Formatter
    private let amountFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter
    }()
    
    var body: some View {
        Form {
            Section("Invoice Details") {
                TextField("Invoice Number", text: $invoice.invoiceNumber)
                DatePicker("Date", selection: $invoice.date, displayedComponents: .date)
                
                Picker("Status", selection: $invoice.status) {
                    ForEach(InvoiceStatus.allCases) { status in
                        Text(status.displayName).tag(status)
                    }
                }
                
                TextField("Amount", value: $invoice.amount, format: .currency(code: "USD"))
            }
        }
        .navigationTitle(invoice.invoiceNumber.isEmpty ? "New Invoice" : invoice.invoiceNumber)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Invoice.self, configurations: config)
    let example = Invoice(invoiceNumber: "INV-001", date: Date(), amount: 1500.00, status: .draft)
    
    return InvoiceDetailView(invoice: example)
        .modelContainer(container)
}
