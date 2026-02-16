import Foundation
import SwiftData

@Model
final class Material {
    var code: String
    var materialDescription: String
    var unit: String
    var rate: Double
    var supplier: String
    var createdAt: Date
    
    init(code: String, materialDescription: String, unit: String, rate: Double, supplier: String) {
        self.code = code
        self.materialDescription = materialDescription
        self.unit = unit
        self.rate = rate
        self.supplier = supplier
        self.createdAt = Date()
    }
}
