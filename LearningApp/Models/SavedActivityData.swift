
import Foundation

struct SavedActivityData: Codable {
    var learnedDates: [Date]
    var frozenDates: [Date]
    var lastActionDate: Date?
    var goalStartedAt: Date?
    var goalSubject: String?
    var goalDuration: String?
}
