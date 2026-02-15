import SwiftUI

struct CableCalculatorView: View {
    
    @State private var loadCurrent: String = ""
    @State private var voltage: String = "230"
    @State private var cableLength: String = ""
    @State private var selectedMethod: InstallationMethod = .air
    @State private var selectedPhase: PhaseType = .single
    
    @State private var resultText: String = "Enter values to calculate."
    
    var body: some View {
        Form {
            Section(header: Text("Input Parameters")) {
                TextField("Load Current (Amps)", text: $loadCurrent)
                    .keyboardType(.decimalPad)
                
                TextField("System Voltage (V)", text: $voltage)
                    .keyboardType(.numberPad)
                
                TextField("Cable Length (meters)", text: $cableLength)
                    .keyboardType(.decimalPad)
                
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
            
            Section(header: Text("Results")) {
                Text(resultText)
                    .font(.headline)
                    .foregroundColor(.blue)
                
                Button("Calculate Size") {
                    calculate()
                }
            }
        }
        .padding()
        .navigationTitle("Cable Sizer")
    }
    
    private func calculate() {
        guard let load = Double(loadCurrent),
              let volts = Double(voltage),
              let length = Double(cableLength) else {
            resultText = "Please enter valid numbers."
            return
        }
        
        let result = CableSizingService.calculateCableSize(
            load: load,
            voltage: volts,
            length: length,
            method: selectedMethod,
            phase: selectedPhase
        )
        
        if let res = result {
            resultText = """
            Selected Cable: \(res.selectedCable)
            Voltage Drop: \(String(format: "%.2f", res.voltageDrop)) V
            Drop %: \(String(format: "%.2f", res.voltageDropPercent))%
            Required Current: \(String(format: "%.2f", res.requiredCurrent)) A
            """
        } else {
            resultText = "No suitable cable found within standard range."
        }
    }
}

// Preview provider for SwiftUI canvas
struct CableCalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        CableCalculatorView()
    }
}
