import Foundation
import SwiftData

@Model
final class CableCalculation {
    var id: UUID
    var timestamp: Date
    var loadCurrent: Double
    var voltage: Double
    var length: Double
    var cableSize: String
    var voltageDrop: Double
    var percentageDrop: Double
    var installationMethod: String // "air" or "ground"
    var phase: String // "single" or "three"
    
    // Relationship back to Project
    var project: Project?
    
    init(load: Double, voltage: Double, length: Double, size: String, drop: Double, percentage: Double, method: String, phase: String) {
        self.id = UUID()
        self.timestamp = Date()
        self.loadCurrent = load
        self.voltage = voltage
        self.length = length
        self.cableSize = size
        self.voltageDrop = drop
        self.percentageDrop = percentage
        self.installationMethod = method
        self.phase = phase
    }
}
