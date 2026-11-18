import SwiftUI
struct ActivityCalendarView: View {
    @ObservedObject var viewModel: ActivityViewModel
    @Binding var selectedDate: Date
    @Environment(\.dismiss) private var dismiss

    private let calendar = Calendar(identifier: .gregorian)

    private var months: [Date] {
        let year = calendar.component(.year, from: .now)
        var components = DateComponents()
        components.year = year
        components.month = 1
        components.day = 1
        guard let start = calendar.date(from: components) else { return [] }
        return (0..<12).compactMap {
            calendar.date(byAdding: .month, value: $0, to: start)
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            navigationHeader

            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(months, id: \.self) { month in
                        NativeMonthCalendar(
                            month: month,
                            selectedDate: $selectedDate,
                            viewModel: viewModel
                        )
                        .frame(minHeight: 280)

                        if month != months.last {
                            Rectangle()
                                .fill(Color(uiColor: .separator).opacity(0.45))
                                .frame(height: 0.5)
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .background(Color(uiColor: .systemBackground))
        .toolbar(.hidden, for: .navigationBar)
    }

    private var navigationHeader: some View {
        ZStack {
            Text("Activities")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.primary)

            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(.primary)
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .accessibilityLabel("Back to activity")
                Spacer()
            }
        }
        .frame(height: 44)
    }
}

private struct NativeMonthCalendar: View {
    let month: Date
    @Binding var selectedDate: Date
    let viewModel: ActivityViewModel
    private let calendar = Calendar(identifier: .gregorian)
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(month.formatted(.dateTime.month(.wide).year().locale(Locale(identifier: "en_US"))))
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.primary)
                .padding(.bottom, 16)

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"], id: \.self) { name in
                    Text(name)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }

                ForEach(monthCells, id: \.self) { date in
                    if let date {
                        dayButton(date)
                    } else {
                        Text("")
                            .frame(height: 34)
                    }
                }
            }
        }
        .padding(.top, 4)
        .padding(.bottom, 8)
    }

    private var monthCells: [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: month),
              let first = calendar.date(from: calendar.dateComponents([.year, .month], from: month)) else {
            return []
        }
        let weekday = calendar.component(.weekday, from: first)
        let leading = weekday - 1
        var cells = Array<Date?>(repeating: nil, count: leading)
        cells += (range).compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: first)
        }
        while cells.count % 7 != 0 {
            cells.append(nil)
        }
        return cells
    }

    private func dayButton(_ date: Date) -> some View {
        let day = calendar.startOfDay(for: date)
        let today = calendar.startOfDay(for: .now)
        let selected = calendar.isDate(day, inSameDayAs: selectedDate)
        let learned = viewModel.isLearned(on: day)
        let frozen = viewModel.isFrozen(on: day)
        let beforeGoal = viewModel.goalStartedAt.map {
            day < calendar.startOfDay(for: $0)
        } ?? false
        let future = day > today

        return Button {
            guard !beforeGoal && !future else { return }
            selectedDate = day
        } label: {
            Text("\(calendar.component(.day, from: day))")
                .font(.system(size: 20, weight: selected ? .semibold : .regular))
                .foregroundStyle(
                    selected ? Color.white :
                    frozen ? Color.cyan :
                    learned ? Color.orange :
                    beforeGoal || future ? Color.secondary.opacity(0.4) :
                    Color.primary
                )
                .frame(height: 34)
                .frame(maxWidth: .infinity)
                .background {
                    if selected {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 34, height: 34)
                    } else if learned {
                        Circle()
                            .fill(Color.orange.opacity(0.10))
                            .overlay(Circle().stroke(Color.orange.opacity(0.35), lineWidth: 1))
                            .frame(width: 34, height: 34)
                    } else if frozen {
                        Circle()
                            .fill(Color.cyan.opacity(0.10))
                            .overlay(Circle().stroke(Color.cyan.opacity(0.35), lineWidth: 1))
                            .frame(width: 34, height: 34)
                    }
                }
        }
        .buttonStyle(.plain)
        .disabled(beforeGoal || future)
        .accessibilityLabel(day.formatted(date: .complete, time: .omitted))
    }
}
