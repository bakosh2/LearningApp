
import SwiftUI
import Combine

final class ActivityViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published private(set) var learnedDates: Set<Date> = []
    @Published private(set) var frozenDates: Set<Date> = []

    private let calendar = Calendar.current

    // MARK: - Date Helper

    private func normalizedDate(_ date: Date) -> Date {
        calendar.startOfDay(for: date)
    }

    // MARK: - Freeze Limits

    func freezeLimit(for duration: String) -> Int {

        switch duration {

        case "Week":
            return 2

        case "Month":
            return 8

        case "Year":
            return 96

        default:
            return 2
        }
    }

    // MARK: - Statistics

    func freezesUsed(for duration: String) -> Int {
        frozenDates.count
    }

    // MARK: - Check Activity

    func isLearned(on date: Date) -> Bool {
        learnedDates.contains(normalizedDate(date))
    }

    func isFrozen(on date: Date) -> Bool {
        frozenDates.contains(normalizedDate(date))
    }

    func isCompleted(on date: Date) -> Bool {
        isLearned(on: date) || isFrozen(on: date)
    }

    // MARK: - Log Learned

    func logLearned(on date: Date) {

        let normalized = normalizedDate(date)

        guard normalized <= normalizedDate(Date()) else {
            return
        }

        guard !isCompleted(on: normalized) else {
            return
        }

        learnedDates.insert(normalized)
    }

    // MARK: - Freeze Day

    func canFreeze(
        on date: Date,
        duration: String
    ) -> Bool {

        let normalized = normalizedDate(date)

        return normalized <= normalizedDate(Date()) &&
        !isCompleted(on: normalized) &&
        frozenDates.count < freezeLimit(for: duration)
    }

    func freezeDay(
        on date: Date,
        duration: String
    ) {

        let normalized = normalizedDate(date)

        guard canFreeze(
            on: normalized,
            duration: duration
        ) else {
            return
        }

        frozenDates.insert(normalized)
    }

    // MARK: - Reset Activity

    func resetActivity() {

        learnedDates.removeAll()
        frozenDates.removeAll()
    }
}
