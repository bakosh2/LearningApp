
import Foundation

struct SavedActivityData: Codable {
    var learnedDates: [Date]
    var frozenDates: [Date]
    var lastActionDate: Date?
}
