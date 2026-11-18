import SwiftUI

struct ActivityView: View {
    @StateObject private var viewModel = ActivityViewModel()
    @State private var subject: String
    @State private var duration: String
    @State private var selectedDate = Calendar.current.startOfDay(for: .now)
    @State private var showingGoalEditor = false
    @State private var showingCalendar = false
    @State private var showingGoalCompleted = false
    @State private var goalWasSuccessful = false

    let onSetNewGoal: () -> Void

    private let calendar = Calendar(identifier: .gregorian)
    private let orange = Color.orange
    private let blue = Color.cyan
    private let navy = Color(red: 0.055, green: 0.075, blue: 0.145)

    init(subject: String, duration: String, onSetNewGoal: @escaping () -> Void = {}) {
        _subject = State(initialValue: subject)
        _duration = State(initialValue: duration)
        self.onSetNewGoal = onSetNewGoal
    }

    private var today: Date { calendar.startOfDay(for: .now) }
    private var selectedDayIsFuture: Bool { selectedDate > today }
    private var selectedDayIsBeforeGoal: Bool {
        guard let goalStartedAt = viewModel.goalStartedAt else { return false }
        return selectedDate < calendar.startOfDay(for: goalStartedAt)
    }
    private var isLearned: Bool { viewModel.isLearned(on: selectedDate) }
    private var isFrozen: Bool { viewModel.isFrozen(on: selectedDate) }
    private var goalCompleted: Bool { viewModel.goalStatus(duration: duration) != .active }
    private var canLearn: Bool { !goalCompleted && !selectedDayIsBeforeGoal && !selectedDayIsFuture && !viewModel.isCompleted(on: selectedDate) }
    private var canFreeze: Bool { !goalCompleted && !selectedDayIsBeforeGoal && viewModel.canFreeze(on: selectedDate, duration: duration) }

    private var weekDates: [Date] {
        let weekday = calendar.component(.weekday, from: selectedDate)
        guard let start = calendar.date(byAdding: .day, value: 1 - weekday, to: selectedDate) else { return [] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
    }

    var body: some View {
        // Refresh once a minute so the 32-hour streak limit and goal deadline stay current.
        TimelineView(.periodic(from: .now, by: 60)) { timeline in
            VStack(spacing: 0) {
                header
                weekStrip
                    .padding(.top, 18)
                streakCards
                    .padding(.top, 14)
                Spacer(minLength: 18)
                logButton
                freezeButton
                    .padding(.top, 14)
                Text("\(viewModel.freezesUsed) out of \(viewModel.freezeLimit(for: duration)) Freezes used")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .padding(.top, 12)
                Spacer(minLength: 18)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(uiColor: .systemBackground))
            .onAppear {
                viewModel.beginGoalIfNeeded(at: timeline.date, subject: subject, duration: duration)
                handleGoalStatus(viewModel.goalStatus(duration: duration, at: timeline.date))
            }
            .onChange(of: viewModel.goalStatus(duration: duration, at: timeline.date)) { _, status in
                handleGoalStatus(status)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showingGoalEditor) {
            GoalEditSheet(subject: subject, duration: duration) { newSubject, newDuration in
                if subject != newSubject || duration != newDuration {
                    subject = newSubject
                    duration = newDuration
                    viewModel.resetActivity()
                    viewModel.beginGoalIfNeeded(subject: newSubject, duration: newDuration)
                    selectedDate = today
                }
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.hidden)
        }
        .navigationDestination(isPresented: $showingCalendar) {
            ActivityCalendarView(viewModel: viewModel, selectedDate: $selectedDate)
        }
        .navigationDestination(isPresented: $showingGoalCompleted) {
            GoalCompletedView(isSuccessful: goalWasSuccessful) {
                viewModel.resetActivity()
                onSetNewGoal()
            }
        }
        .animation(.snappy(duration: 0.25), value: selectedDate)
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Activity")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.primary)
                Text(selectedDate.formatted(.dateTime.weekday(.wide).day().month(.wide).locale(Locale(identifier: "en_US"))))
                    .font(.system(size: 17))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button { showingCalendar = true } label: {
                Image(systemName: "calendar")
                    .font(.system(size: 19, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial, in: Circle())
                    .overlay(Circle().stroke(.white.opacity(0.10), lineWidth: 0.5))
            }
            .accessibilityLabel("Open activity calendar")
            Button { showingGoalEditor = true } label: {
                Image(systemName: "pencil.and.outline")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundStyle(.white)
                    .overlay(alignment: .topTrailing) {
                        Image(systemName: "pencil")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(.white)
                            .offset(x: 4, y: -2)
                    }
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial, in: Circle())
                    .overlay(Circle().stroke(.white.opacity(0.10), lineWidth: 0.5))
            }
            .accessibilityLabel("Edit learning goal")
        }
    }

    private func handleGoalStatus(_ status: ActivityViewModel.GoalStatus) {
        guard status != .active else { return }
        goalWasSuccessful = status == .succeeded
        showingGoalCompleted = true
    }

    private var weekStrip: some View {
        HStack(spacing: 0) {
            ForEach(weekDates, id: \.self) { date in
                let selected = calendar.isDate(date, inSameDayAs: selectedDate)
                let learned = viewModel.isLearned(on: date)
                let frozen = viewModel.isFrozen(on: date)
                Button {
                    withAnimation(.snappy(duration: 0.25)) { selectedDate = date }
                } label: {
                    VStack(spacing: 2) {
                        Text(weekdayLetter(for: date))
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.secondary)
                        ZStack {
                            Circle()
                                .fill(selected ? orange : .clear)
                            Text(String(calendar.component(.day, from: date)))
                                .font(.system(size: 20, weight: selected ? .semibold : .regular))
                                .foregroundStyle(selected ? Color.white : learned ? orange : frozen ? blue : Color.primary)
                        }
                        .frame(width: 44, height: 44)
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(date < calendar.startOfDay(for: viewModel.goalStartedAt ?? date) || date > today)
                .accessibilityLabel(date.formatted(date: .complete, time: .omitted))
            }
        }
    }

    private func weekdayLetter(for date: Date) -> String {
        let index = calendar.component(.weekday, from: date) - 1
        return ["S", "M", "T", "W", "T", "F", "S"][index]
    }

    private var streakCards: some View {
        HStack(spacing: 12) {
            statisticCard(icon: "flame.fill", color: orange, count: viewModel.streakCount, title: "Learned")
            statisticCard(icon: "snowflake", color: blue, count: viewModel.freezesUsed, title: "Freezed")
        }
    }

    private func statisticCard(icon: String, color: Color, count: Int, title: String) -> some View {
        VStack(spacing: 2) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(color)
            Text("\(count) \(count == 1 ? "day" : "days")")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.primary)
            Text(title)
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.22), .white.opacity(0.07)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }

    private var logButton: some View {
        Button {
            viewModel.logLearned(on: selectedDate)
            if viewModel.isGoalCompleted(duration: duration) {
                goalWasSuccessful = true
                showingGoalCompleted = true
            }
        } label: {
            Text(isLearned ? "Logged as Learned" : isFrozen ? "Freezed for a day" : "Log as Learned")
                .font(.system(size: 18, weight: .semibold))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 18)
                .foregroundStyle(canLearn ? Color.white : Color.secondary)
                .frame(width: 300, height: 300)
                .background {
                    if canLearn {
                        Circle()
                            .fill(.orange)
                            .overlay(Circle().stroke(.white.opacity(0.12), lineWidth: 1))
                    } else {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .overlay(Circle().stroke(.white.opacity(0.72), lineWidth: 1))
                    }
                }
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .disabled(!canLearn || goalCompleted)
        .accessibilityHint("Records this date as a learning day")
    }

    private var freezeButton: some View {
        Button { viewModel.freezeDay(on: selectedDate, duration: duration) } label: {
            Text(isFrozen ? "Freezed for a day" : "Freeze for a day")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(canFreeze ? Color.white : .secondary)
                .frame(width: 272, height: 46)
        }
        .buttonStyle(.glassProminent)
        .tint(canFreeze ? blue : Color(uiColor: .secondarySystemBackground))
        .disabled(!canFreeze)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack { ActivityView(subject: "Swift", duration: "Week") }
}
