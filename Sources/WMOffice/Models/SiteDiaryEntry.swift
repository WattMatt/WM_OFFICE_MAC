import SwiftData
import Foundation

@Model
final class SiteDiaryEntry {
    var date: Date
    var weatherSummary: String
    var notes: String
    var tasks: [String] // Simple array of task descriptions
    
    // Optional: Linking to a project if the architecture supports it, 
    // but the prompt didn't specify, so I'll keep it standalone for now.
    
    init(date: Date = Date(), weatherSummary: String = "", notes: String = "", tasks: [String] = []) {
        self.date = date
        self.weatherSummary = weatherSummary
        self.notes = notes
        self.tasks = tasks
    }
}
