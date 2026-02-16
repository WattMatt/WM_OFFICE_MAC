import SwiftUI
import SwiftData

struct CableScheduleView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var cableRuns: [CableRun]
    
    // Mock service for calculation
    private let sizingService = CableSizingService()
    
    @State private var selection = Set<CableRun.ID>()
    
    var body: some View {
        Table(cableRuns, selection: $selection) {
            TableColumn("Tag", value: \.tag)
            TableColumn("From", value: \.from)
            TableColumn("To", value: \.to)
            TableColumn("Load (A)") { run in
                Text(String(format: "%.1f", run.load))
            }
            TableColumn("Length (m)") { run in
                Text(String(format: "%.1f", run.length))
            }
            TableColumn("Cable Size") { run in
                Text(run.cableSize ?? "-")
            }
            TableColumn("Voltage Drop") { run in
                if let vd = run.voltageDrop {
                    Text(String(format: "%.2f V", vd))
                } else {
                    Text("-")
                }
            }
            TableColumn("Actions") { run in
                Button("Calculate") {
                    calculateRun(run)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
        }
        .navigationTitle("Cable Schedules")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: addRun) {
                    Label("Add Run", systemImage: "plus")
                }
            }
        }
    }
    
    private func addRun() {
        // Default placeholder for new entry
        let newRun = CableRun(tag: "New", from: "Source", to: "Dest", load: 0.0, length: 0.0)
        modelContext.insert(newRun)
    }
    
    private func calculateRun(_ run: CableRun) {
        // Simulate calculation service update
        let result = sizingService.calculate(load: run.load, length: run.length)
        run.cableSize = result.size
        run.voltageDrop = result.voltageDrop
    }
}

// Placeholder service to satisfy the requirement
struct CableSizingService {
    func calculate(load: Double, length: Double) -> (size: String, voltageDrop: Double) {
        // Mock calculation logic
        let size = load > 50 ? "16mm²" : "6mm²"
        let vd = (load * length * 0.004) // Mock formula
        return (size, vd)
    }
}
