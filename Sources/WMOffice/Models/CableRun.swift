import Foundation
import SwiftData

@Model
final class CableRun {
    var tag: String
    var from: String
    var to: String
    var load: Double // Amps or kW, defaulting to Amps for now
    var length: Double // Meters
    var cableSize: String?
    var voltageDrop: Double?
    
    init(tag: String, from: String, to: String, load: Double, length: Double, cableSize: String? = nil, voltageDrop: Double? = nil) {
        self.tag = tag
        self.from = from
        self.to = to
        self.load = load
        self.length = length
        self.cableSize = cableSize
        self.voltageDrop = voltageDrop
    }
}
