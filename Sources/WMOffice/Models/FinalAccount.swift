import Foundation
import SwiftData

@Model
final class FinalAccount {
    var boqItem: String
    var originalQty: Double
    var finalQty: Double
    var rate: Double
    
    // Computed property for variance
    var variance: Double {
        return (finalQty - originalQty) * rate
    }
    
    // Optional: Link to a project if needed, but keeping it simple as per prompt specs for now.
    // In a real app, this would likely belong to a Project.
    
    init(boqItem: String, originalQty: Double, finalQty: Double, rate: Double) {
        self.boqItem = boqItem
        self.originalQty = originalQty
        self.finalQty = finalQty
        self.rate = rate
    }
}
