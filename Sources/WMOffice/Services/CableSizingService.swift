import Foundation

struct CableData {
    let size: String
    let ratingAir: Double
    let ratingGround: Double
    let impedance: Double // milli-ohms per meter
}

enum InstallationMethod: String, CaseIterable, Identifiable {
    case air
    case ground
    
    var id: String { rawValue }
}

enum PhaseType: String, CaseIterable, Identifiable {
    case single
    case three
    
    var id: String { rawValue }
}

struct CalculationResult {
    let selectedCable: String
    let voltageDrop: Double
    let voltageDropPercent: Double
    let isFeasible: Bool
    let requiredCurrent: Double
}

class CableSizingService {
    
    // Engineering Spec Data
    private static let safetyFactor = 1.15
    private static let maxVoltageDropPercentSingle = 3.0
    private static let maxVoltageDropPercentThree = 5.0
    
    private static let cableTable: [CableData] = [
        CableData(size: "1.5mm²", ratingAir: 19, ratingGround: 24, impedance: 14.48),
        CableData(size: "2.5mm²", ratingAir: 26, ratingGround: 32, impedance: 8.87),
        CableData(size: "4mm²", ratingAir: 35, ratingGround: 42, impedance: 5.52),
        CableData(size: "6mm²", ratingAir: 45, ratingGround: 53, impedance: 3.69),
        CableData(size: "10mm²", ratingAir: 62, ratingGround: 70, impedance: 2.19),
        CableData(size: "16mm²", ratingAir: 83, ratingGround: 91, impedance: 1.38)
    ]
    
    /// Calculates the minimum cable size required based on load, voltage, length and installation method.
    /// - Parameters:
    ///   - load: The load current in Amperes.
    ///   - voltage: The system voltage (e.g., 230 for single phase, 400 for three phase).
    ///   - length: The length of the cable run in meters.
    ///   - method: Installation method (.air or .ground).
    ///   - phase: Phase type (.single or .three). Defaults to single if not specified (though voltage implies it usually).
    /// - Returns: A CalculationResult containing the selected cable and details.
    static func calculateCableSize(load: Double, voltage: Double, length: Double, method: InstallationMethod, phase: PhaseType = .single) -> CalculationResult? {
        
        let designCurrent = load * safetyFactor
        let maxDropPercent = (phase == .single) ? maxVoltageDropPercentSingle : maxVoltageDropPercentThree
        let maxVoltageDrop = (voltage * maxDropPercent) / 100.0
        
        // Iterate through cables to find the first one that satisfies both current rating and voltage drop
        for cable in cableTable {
            let currentRating = (method == .air) ? cable.ratingAir : cable.ratingGround
            
            // Check 1: Current Carrying Capacity
            if currentRating >= designCurrent {
                
                // Check 2: Voltage Drop
                // Voltage Drop (V) = (mV/A/m) * I * L / 1000
                
                let rOhmsPerMeter = cable.impedance / 1000.0
                let drop: Double
                
                if phase == .single {
                    // Single Phase Voltage Drop = 2 * L * (R/1000) * I
                    drop = 2 * length * rOhmsPerMeter * load
                } else {
                    // Three Phase Voltage Drop = sqrt(3) * L * (R/1000) * I
                    drop = sqrt(3) * length * rOhmsPerMeter * load
                }
                
                if drop <= maxVoltageDrop {
                    return CalculationResult(
                        selectedCable: cable.size,
                        voltageDrop: drop,
                        voltageDropPercent: (drop / voltage) * 100.0,
                        isFeasible: true,
                        requiredCurrent: designCurrent
                    )
                }
            }
        }
        
        return nil // No suitable cable found in the standard list
    }
}
