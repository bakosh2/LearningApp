
import SwiftUI
import UIKit

struct ActivityView: View {

    @StateObject private var viewModel = ActivityViewModel()

    @State private var subject: String
    @State private var duration: String
    @State private var selectedDate = Calendar.current.startOfDay(for: Date())
    @State private var showGoalEditor = false

    private let calendar = Calendar.current

    private let accentColor = Color.orange
    private let freezeColor = Color.cyan

    init(subject: String, duration: String) {
        _subject = State(initialValue: subject)
        _duration = State(initialValue: duration)
    }

    private var today: Date {
        calendar.startOfDay(for: Date())
    }

    private var isLearned: Bool {
        viewModel.isLearned(on: selectedDate)
    }

    private var isFrozen: Bool {
        viewModel.isFrozen(on: selectedDate)
    }

    private var canLearn: Bool {
        selectedDate <= today &&
        !viewModel.isCompleted(on: selectedDate)
    }

    private var canFreeze: Bool {
        viewModel.canFreeze(
            on: selectedDate,
            duration: duration
        )
    }

    private var weekDates: [Date] {
        guard let weekStart = calendar.dateInterval(
            of: .weekOfYear,
            for: selectedDate
        )?.start else {
            return []
        }

        return (0..<7).compactMap { day in
            calendar.date(
                byAdding: .day,
                value: day,
                to: weekStart
            )
        }
    }

    var body: some View {

        ZStack {

            Color(uiColor: .systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {

                headerView

                weeklyCalendar

                statisticsView
                    .padding(.top, 14)

                Spacer(minLength: 25)

                learnedButton

                freezeButton
                    .padding(.top, 40)

                Text(
                    "\(viewModel.freezesUsed(for: duration)) out of \(viewModel.freezeLimit(for: duration)) Freezes used"
                )
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .padding(.top, 12)

                Spacer(minLength: 25)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showGoalEditor) {

            GoalEditSheet(
                subject: subject,
                duration: duration
            ) { newSubject, newDuration in

                let goalChanged =
                    subject != newSubject ||
                    duration != newDuration

                subject = newSubject
                duration = newDuration

                if goalChanged {
                    viewModel.resetActivity()
                    selectedDate = today
                }
            }
        }
    }

    // MARK: - Header

    private var headerView: some View {

        HStack {

            VStack(alignment: .leading, spacing: 4) {

                Text("Activity")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.primary)

                Text(
                    selectedDate.formatted(
                        .dateTime
                            .weekday(.wide)
                            .day()
                            .month(.wide)
                    )
                )
                .font(.system(size: 16))
                .foregroundStyle(.secondary)
            }

            Spacer()

            Button {

                if let url = URL(string: "calshow://") {
                    UIApplication.shared.open(url)
                }

            } label: {

                Image(systemName: "calendar")
                    .font(.system(size: 21))
                    .frame(width: 46, height: 46)
            }
            .buttonStyle(.glass)
            .buttonBorderShape(.circle)

            Button {

                showGoalEditor = true

            } label: {

                Image(systemName: "pencil")
                    .font(.system(size: 21))
                    .frame(width: 46, height: 46)
            }
            .buttonStyle(.glass)
            .buttonBorderShape(.circle)
        }
    }

    // MARK: - Weekly Calendar

    private var weeklyCalendar: some View {

        HStack(spacing: 0) {

            ForEach(weekDates, id: \.self) { date in

                let dayNumber = calendar.component(
                    .day,
                    from: date
                )

                let weekday = date.formatted(
                    .dateTime.weekday(.narrow)
                )

                let isSelected = calendar.isDate(
                    date,
                    inSameDayAs: selectedDate
                )

                let learned = viewModel.isLearned(on: date)
                let frozen = viewModel.isFrozen(on: date)

                Button {

                    selectedDate = date

                } label: {

                    VStack(spacing: 8) {

                        Text(weekday)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.primary)

                        Text("\(dayNumber)")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(
                                isSelected ? .white :
                                frozen ? freezeColor :
                                learned ? accentColor :
                                .primary
                            )
                            .frame(width: 44, height: 44)
                            .background {

                                Circle()
                                    .fill(
                                        isSelected ? accentColor :
                                        frozen ? freezeColor.opacity(0.15) :
                                        learned ? accentColor.opacity(0.15) :
                                        Color.clear
                                    )
                            }
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 18)
    }

    // MARK: - Statistics

    private var statisticsView: some View {

        HStack(spacing: 12) {

            statisticsCard(
                icon: "flame.fill",
                iconColor: accentColor,
                number: viewModel.learnedDates.count,
                title: "Learned"
            )

            statisticsCard(
                icon: "snowflake",
                iconColor: freezeColor,
                number: viewModel.frozenDates.count,
                title: "Freezed"
            )
        }
    }

    private func statisticsCard(
        icon: String,
        iconColor: Color,
        number: Int,
        title: String
    ) -> some View {

        VStack(spacing: 5) {

            Image(systemName: icon)
                .font(.system(size: 19))
                .foregroundStyle(iconColor)

            Text("\(number) days")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.primary)

            Text(title)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .background {

            RoundedRectangle(cornerRadius: 35)
                .fill(.ultraThinMaterial)
                .overlay {

                    RoundedRectangle(cornerRadius: 35)
                        .stroke(
                            Color(uiColor: .separator).opacity(0.4),
                            lineWidth: 1
                        )
                }
        }
    }

    // MARK: - Learned Button

    private var learnedButton: some View {

        Button {

            viewModel.logLearned(on: selectedDate)

        } label: {

            Text(
                isLearned ? "Logged as Learned" :
                isFrozen ? "Frozen for a day" :
                "Log as Learned"
            )
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 270, height: 270)
        }
        .buttonStyle(.glassProminent)
        .buttonBorderShape(.circle)
        .tint(canLearn ? accentColor : .secondary)
        .disabled(!canLearn)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Freeze Button

    private var freezeButton: some View {

        Button {

            viewModel.freezeDay(
                on: selectedDate,
                duration: duration
            )

        } label: {

            Text(
                isFrozen ? "Freezed for a day" :
                "Freeze for a day"
            )
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 46)
        }
        .buttonStyle(.glassProminent)
        .tint(canFreeze ? freezeColor : .secondary)
        .disabled(!canFreeze)
        .padding(.horizontal, 46)
    }
}

#Preview {
    NavigationStack {
        ActivityView(
            subject: "Swift",
            duration: "Week"
        )
    }
}
