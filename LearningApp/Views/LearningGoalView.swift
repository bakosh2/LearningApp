import SwiftUI

enum GoalFormStyle {
    static let label = Font.system(size: 16)
    static let field = Font.system(size: 16)
    static let option = Font.system(size: 16, weight: .medium)
    static let horizontalPadding: CGFloat = 16
    static let sectionSpacing: CGFloat = 34
    static let optionHeight: CGFloat = 46
    static let optionPadding: CGFloat = 20
    static let optionSpacing: CGFloat = 12
}

struct LearningGoalView: View {
    @StateObject private var viewModel = LearningGoalViewModel()
    @State private var showActivity = false
    @FocusState private var goalIsFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 38, weight: .semibold))
                    .foregroundStyle(.orange)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 78)

                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text("Hello")
                        .font(.system(size: 34, weight: .regular))
                    Text("Learner")
                        .font(.system(size: 34, weight: .bold))
                }
                .foregroundStyle(.primary)
                Text("This app will help you learn everyday!")
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
                    .padding(.top, 0)

                Text("I want to learn")
                    .font(GoalFormStyle.label)
                    .foregroundStyle(.primary)
                    .padding(.top, 36)
                TextField("What do you want to learn?", text: $viewModel.subject)
                    .font(GoalFormStyle.field)
                    .textInputAutocapitalization(.sentences)
                    .focused($goalIsFocused)
                    .padding(.vertical, 18)
                    .overlay(alignment: .bottom) { Rectangle().fill(Color(uiColor: .separator).opacity(0.4)).frame(height: 0.5) }

                Text("I want to learn it in a")
                    .font(GoalFormStyle.label)
                    .foregroundStyle(.primary)
                    .padding(.top, GoalFormStyle.sectionSpacing)
                    .padding(.bottom, 10)
                durationPicker

                Spacer(minLength: 28)

                Button {
                    goalIsFocused = false
                    showActivity = true
                } label: {
                    Text("Start Learning")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 152, height: 44)
                }
                .buttonStyle(.glassProminent)
                .tint(.orange)
                .disabled(!viewModel.canContinue)
                .opacity(viewModel.canContinue ? 1 : 0.55)
                .frame(maxWidth: .infinity)
                Text("You can edit your desire later")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
            }
            .padding(.horizontal, GoalFormStyle.horizontalPadding)
            .padding(.top, 60)
            .padding(.bottom, 18)
            .frame(maxWidth: 440)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color(uiColor: .systemBackground))
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: $showActivity) {
                ActivityView(subject: viewModel.subject, duration: viewModel.duration) {
                    viewModel.subject = "Swift"
                    viewModel.duration = "Week"
                    showActivity = false
                }
            }
        }
    }

    private var durationPicker: some View {
        HStack(spacing: GoalFormStyle.optionSpacing) {
            ForEach(viewModel.durations, id: \.self) { duration in
                let selected = viewModel.duration == duration
                if selected {
                    Button { viewModel.duration = duration } label: {
                        Text(duration)
                            .font(GoalFormStyle.option)
                            .foregroundStyle(.white)
                            .padding(.horizontal, GoalFormStyle.optionPadding)
                            .frame(height: GoalFormStyle.optionHeight)
                    }
                    .buttonStyle(.glassProminent)
                    .tint(.orange)
                } else {
                    Button { viewModel.duration = duration } label: {
                        Text(duration)
                            .font(GoalFormStyle.option)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, GoalFormStyle.optionPadding)
                            .frame(height: GoalFormStyle.optionHeight)
                    }
                    .buttonStyle(.glass)
                }
            }
        }
    }
}

#Preview {
    LearningGoalView()
}
