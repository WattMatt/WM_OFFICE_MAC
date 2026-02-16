import SwiftUI
import SwiftData

struct InvoiceListView: View {
    @Binding var selection: Invoice?
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Invoice.date, order: .reverse) private var invoices: [Invoice]
    @State private var showingAddInvoice = false

    var body: some View {
        List(invoices, selection: $selection) { invoice in
            NavigationLink(value: invoice) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(invoice.invoiceNumber)
                            .font(.headline)
                        Text(invoice.date.formatted(date: .numeric, time: .omitted))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text(invoice.amount.formatted(.currency(code: "USD")))
                            .font(.headline)
                        
                        statusBadge(for: invoice.status)
                    }
                }
            }
        }
        .navigationTitle("Invoices")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: addInvoice) {
                    Label("Add Invoice", systemImage: "plus")
                }
            }
        }
    }

    private func addInvoice() {
        withAnimation {
            let newInvoice = Invoice(invoiceNumber: "New Invoice", date: Date(), amount: 0.0, status: .draft)
            modelContext.insert(newInvoice)
            selection = newInvoice
        }
    }
    
    @ViewBuilder
    private func statusBadge(for status: InvoiceStatus) -> some View {
        Text(status.displayName)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor(for: status).opacity(0.2))
            .foregroundStyle(statusColor(for: status))
            .clipShape(Capsule())
    }
    
    private func statusColor(for status: InvoiceStatus) -> Color {
        switch status {
        case .draft: return .gray
        case .sent: return .blue
        case .paid: return .green
        }
    }
}

#Preview {
    InvoiceListView(selection: .constant(nil))
        .modelContainer(for: Invoice.self, inMemory: true)
}
