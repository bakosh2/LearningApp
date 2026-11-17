import Foundation
import Combine

final class ActivityViewModel: ObservableObject {
    enum GoalStatus: Equatable {
        case active
        case succeeded
        case expired
    }

    @Published private(set) var learnedDates: Set<Date> = []
    @Published private(set) var frozenDates: Set<Date> = []
    @Published private(set) var lastActionDate: Date?
    @Published private(set) var goalStartedAt: Date?
    private var goalSubject: String?
    private var goalDuration: String?

    private let calendar = Calendar.current
    private let storageKey = "savedActivityData"
    private let testBackupKey = "testSavedActivityData"
    private let streakGracePeriod: TimeInterval = 32 * 60 * 60

    init() {
        #if DEBUG
        if CommandLine.arguments.contains("-clearTestWeek") {
            clearTestWeek()
            return
        }
        if CommandLine.arguments.contains("-seedTestWeek") {
            seedTestWeek()
            return
        }
        #endif

        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let saved = try? JSONDecoder().decode(SavedActivityData.self, from: data) else { return }
        learnedDates = Set(saved.learnedDates.map(normalizedDate))
        frozenDates = Set(saved.frozenDates.map(normalizedDate))
        lastActionDate = saved.lastActionDate
        goalStartedAt = saved.goalStartedAt
        goalSubject = saved.goalSubject
        goalDuration = saved.goalDuration
    }

    private func seedTestWeek() {
        let today = calendar.startOfDay(for: .now)
        if let currentData = UserDefaults.standard.data(forKey: storageKey),
           UserDefaults.standard.data(forKey: testBackupKey) == nil {
            UserDefaults.standard.set(currentData, forKey: testBackupKey)
        }
        learnedDates = Set((1...7).compactMap {
            calendar.date(byAdding: .day, value: -$0, to: today)
        })
        frozenDates.removeAll()
        lastActionDate = .now
        goalStartedAt = calendar.date(byAdding: .day, value: -6, to: today)
        goalSubject = "Swift"
        goalDuration = "Week"
        save()
    }

    private func clearTestWeek() {
        if let backup = UserDefaults.standard.data(forKey: testBackupKey) {
            UserDefaults.standard.set(backup, forKey: storageKey)
        } else {
            UserDefaults.standard.removeObject(forKey: storageKey)
        }
        UserDefaults.standard.removeObject(forKey: testBackupKey)

        learnedDates.removeAll()
        frozenDates.removeAll()
        lastActionDate = nil
        goalStartedAt = nil
        goalSubject = nil
        goalDuration = nil

        if let backup = UserDefaults.standard.data(forKey: storageKey),
           let saved = try? JSONDecoder().decode(SavedActivityData.self, from: backup) {
            learnedDates = Set(saved.learnedDates.map(normalizedDate))
            frozenDates = Set(saved.frozenDates.map(normalizedDate))
            lastActionDate = saved.lastActionDate
            goalStartedAt = saved.goalStartedAt
            goalSubject = saved.goalSubject
            goalDuration = saved.goalDuration
        }
    }

    private func normalizedDate(_ date: Date) -> Date {
        calendar.startOfDay(for: date)
    }

    var streakCount: Int {
        guard let lastActionDate,
              Date().timeIntervalSince(lastActionDate) <= streakGracePeriod else { return 0 }

        guard var day = (learnedDates.union(frozenDates)).max() else { return 0 }
        var count = 0
        while learnedDates.contains(day) || frozenDates.contains(day) {
            count += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = previousDay
        }
        return count
    }

    func isGoalCompleted(duration: String) -> Bool {
        let goalDays: Int
        switch duration {
        case "Month": goalDays = 30
        case "Year": goalDays = 365
        default: goalDays = 7
        }
        return learnedDates.count >= goalDays
    }

    func goalStatus(duration: String, at date: Date = .now) -> GoalStatus {
        if isGoalCompleted(duration: duration) { return .succeeded }
        guard let goalStartedAt else { return .active }

        let goalDays = goalDurationDays(duration)
        guard let deadline = calendar.date(byAdding: .day, value: goalDays, to: normalizedDate(goalStartedAt)) else { return .active }
        return date >= deadline ? .expired : .active
    }

    private func goalDurationDays(_ duration: String) -> Int {
        switch duration {
        case "Month":
            return 30
        case "Year":
            return 365
        default:
            return 7
        }
    }

    func beginGoalIfNeeded(at date: Date = .now, subject: String, duration: String) {
        guard goalStartedAt != nil else {
            goalStartedAt = date
            goalSubject = subject
            goalDuration = duration
            save()
            return
        }
        guard goalSubject != subject || goalDuration != duration else { return }
        learnedDates.removeAll()
        frozenDates.removeAll()
        lastActionDate = nil
        goalStartedAt = date
        goalSubject = subject
        goalDuration = duration
        save()
    }

    func freezeLimit(for duration: String) -> Int {
        switch duration {
        case "Month":
            return 8
        case "Year":
            return 96
        default:
            return 2
        }
    }

    var freezesUsed: Int { frozenDates.count }
    func isLearned(on date: Date) -> Bool { learnedDates.contains(normalizedDate(date)) }
    func isFrozen(on date: Date) -> Bool { frozenDates.contains(normalizedDate(date)) }
    func isCompleted(on date: Date) -> Bool { isLearned(on: date) || isFrozen(on: date) }

    func logLearned(on date: Date) {
        let day = normalizedDate(date)
        guard isWithinGoal(day), day <= normalizedDate(.now), !isCompleted(on: day) else { return }
        learnedDates.insert(day)
        lastActionDate = .now
        save()
    }

    func canFreeze(on date: Date, duration: String) -> Bool {
        let day = normalizedDate(date)
        return isWithinGoal(day) && day <= normalizedDate(.now) && !isCompleted(on: day) && frozenDates.count < freezeLimit(for: duration)
    }

    func freezeDay(on date: Date, duration: String) {
        let day = normalizedDate(date)
        guard canFreeze(on: day, duration: duration) else { return }
        frozenDates.insert(day)
        lastActionDate = .now
        save()
    }

    func resetActivity() {
        learnedDates.removeAll()
        frozenDates.removeAll()
        lastActionDate = nil
        goalStartedAt = nil
        goalSubject = nil
        goalDuration = nil
        UserDefaults.standard.removeObject(forKey: storageKey)
    }

    private func save() {
        let saved = SavedActivityData(
            learnedDates: Array(learnedDates),
            frozenDates: Array(frozenDates),
            lastActionDate: lastActionDate,
            goalStartedAt: goalStartedAt,
            goalSubject: goalSubject,
            goalDuration: goalDuration
        )
        guard let data = try? JSONEncoder().encode(saved) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private func isWithinGoal(_ date: Date) -> Bool {
        guard let goalStartedAt else { return false }
        let start = normalizedDate(goalStartedAt)
        let goalDays = goalDurationDays(goalDuration ?? "")
        guard let end = calendar.date(byAdding: .day, value: goalDays, to: start) else { return false }
        return date >= start && date < end
    }
}
