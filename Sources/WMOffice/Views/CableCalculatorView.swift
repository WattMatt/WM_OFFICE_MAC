import SwiftUI
import SwiftData

struct CableCalculatorView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Project.title) private var projects: [Project]
    
    @State private var loadCurrent: String = ""
    @State private var voltage: String = "230"
    @State private var cableLength: String = ""
    @State private var selectedMethod: InstallationMethod = .air
    @State private var selectedPhase: PhaseType = .single
    @State private var selectedProject: Project?
    
    @State private var calculationResult: CalculationResult?
    @State private var showingSaveAlert = false
    
    var body: some View {
        Form {
            Section(header: Text("Input Parameters")) {
                TextField("Load Current (Amps)", text: $loadCurrent)
                #if os(iOS)
                    .keyboardType(.decimalPad)
                #endif
                
                TextField("System Voltage (V)", text: $voltage)
                #if os(iOS)
                    .keyboardType(.numberPad)
                #endif
                
                TextField("Cable Length (meters)", text: $cableLength)
                #if os(iOS)
                    .keyboardType(.decimalPad)
                #endif
                
                Picker("Installation Method", selection: $selectedMethod) {
                    Text("In Air").tag(InstallationMethod.air)
                    Text("In Ground").tag(InstallationMethod.ground)
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Picker("Phase Type", selection: $selectedPhase) {
                    Text("Single Phase").tag(PhaseType.single)
                    Text("Three Phase").tag(PhaseType.three)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            if let result = calculationResult {
                Section(header: Text("Results")) {
                    HStack {
                        Text("Selected Cable:")
                        Spacer()
                        Text(result.selectedCable).bold()
                    }
                    
                    HStack {
                        Text("Voltage Drop:")
                        Spacer()
                        Text(String(format: "%.2f V", result.voltageDrop))
                            .foregroundColor(result.isFeasible ? .primary : .red)
                    }
                    
                    HStack {
                        Text("Drop %:")
                        Spacer()
                        Text(String(format: "%.2f%%", result.voltageDropPercent))
                            .foregroundColor(result.voltageDropPercent > 5.0 ? .red : .green)
                    }
                    
                    HStack {
                        Text("Required Current:")
                        Spacer()
                        Text(String(format: "%.2f A", result.requiredCurrent))
                    }
                }
                
                Section(header: Text("Save to Project")) {
                    Picker("Select Project", selection: $selectedProject) {
                        Text("None").tag(nil as Project?)
                        ForEach(projects) { project in
                            Text(project.title).tag(project as Project?)
                        }
                    }
                    
                    Button(action: saveToProject) {
                        Label("Add to Project", systemImage: "plus.circle.fill")
                    }
                    .disabled(selectedProject == nil)
                }
            } else {
                Section {
                    Text("Enter valid parameters to see results.")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .navigationTitle("Cable Sizer")
        .onChange(of: loadCurrent) { _, _ in calculate() }
        .onChange(of: voltage) { _, _ in calculate() }
        .onChange(of: cableLength) { _, _ in calculate() }
        .onChange(of: selectedMethod) { _, _ in calculate() }
        .onChange(of: selectedPhase) { _, _ in calculate() }
        .alert("Saved", isPresented: $showingSaveAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Calculation saved to project.")
        }
    }
    
    private func calculate() {
        guard let load = Double(loadCurrent),
              let volts = Double(voltage),
              let length = Double(cableLength) else {
            calculationResult = nil
            return
        }
        
        calculationResult = CableSizingService.calculateCableSize(
            load: load,
            voltage: volts,
            length: length,
            method: selectedMethod,
            phase: selectedPhase
        )
    }
    
    private func saveToProject() {
        guard let project = selectedProject,
              let result = calculationResult,
              let load = Double(loadCurrent),
              let volts = Double(voltage),
              let length = Double(cableLength) else { return }
        
        let calculation = CableCalculation(
            load: load,
            voltage: volts,
            length: length,
            size: result.selectedCable,
            drop: result.voltageDrop,
            percentage: result.voltageDropPercent,
            method: selectedMethod.rawValue.capitalized,
            phase: selectedPhase.rawValue.capitalized
        )
        
        // Add to project relationship
        if project.calculations == nil {
            project.calculations = []
        }
        project.calculations?.append(calculation)
        
        // Also insert into context (though relationships often handle this automatically, explicitly inserting is safer)
        modelContext.insert(calculation)
        
        showingSaveAlert = true
    }
}

// Preview provider for SwiftUI canvas
struct CableCalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        CableCalculatorView()
            .modelContainer(for: Project.self, inMemory: true)
    }
}
