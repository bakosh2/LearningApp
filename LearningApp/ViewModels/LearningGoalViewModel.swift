
import SwiftUI
import Combine

class LearningGoalViewModel: ObservableObject {

    @Published var subject = ""
    @Published var duration = "Week"

    let durations = ["Week", "Month", "Year"]

    var canContinue: Bool {
        !subject.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty
    }
}
