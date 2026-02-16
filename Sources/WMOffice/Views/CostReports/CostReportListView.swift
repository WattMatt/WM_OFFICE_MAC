import SwiftUI
import SwiftData

struct CostReportListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CostReport.dateCreated, order: .reverse) private var reports: [CostReport]
    
    @Binding var selection: CostReport?
    
    @State private var showingAddReport = false
    @State private var newReportTitle = ""
    
    init(selection: Binding<CostReport?> = .constant(nil)) {
        _selection = selection
    }
    
    var body: some View {
        List(selection: $selection) {
            ForEach(reports) { report in
                VStack(alignment: .leading) {
                    Text(report.title)
                        .font(.headline)
                    Text(report.dateCreated, format: .dateTime.year().month().day())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .tag(report)
            }
            .onDelete(perform: deleteReports)
        }
        .navigationTitle("Cost Reports")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingAddReport = true }) {
                    Label("Add Report", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddReport) {
            NavigationStack {
                Form {
                    TextField("Report Title", text: $newReportTitle)
                }
                .navigationTitle("New Report")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showingAddReport = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            addReport()
                            showingAddReport = false
                        }
                        .disabled(newReportTitle.isEmpty)
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }
    
    private func addReport() {
        let newReport = CostReport(title: newReportTitle)
        modelContext.insert(newReport)
        newReportTitle = ""
    }
    
    private func deleteReports(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(reports[index])
        }
    }
}
