
import SwiftUI

struct LearningGoalView: View {

    @StateObject private var viewModel = LearningGoalViewModel()

    @State private var showActivity = false

    var body: some View {
        NavigationStack {
            mainContent
                .padding(24)
                .navigationDestination(isPresented: $showActivity) {
                    ActivityView(
                        subject: viewModel.subject,
                        duration: viewModel.duration
                    )
                }
        }
    }

    // MARK: - Main Content

    private var mainContent: some View {
        VStack(spacing: 25) {
            titleSection

            subjectField

            durationSection

            continueButton

            Spacer()
        }
    }

    // MARK: - Title

    private var titleSection: some View {
        Text("What do you want to learn?")
            .font(.largeTitle)
            .fontWeight(.bold)
    }

    // MARK: - Subject Field

    private var subjectField: some View {
        TextField(
            "Enter your learning goal",
            text: $viewModel.subject
        )
        .textFieldStyle(.roundedBorder)
    }

    // MARK: - Duration

    private var durationSection: some View {
        VStack(spacing: 15) {
            Text("I want to learn it in a")
                .font(.headline)

            HStack(spacing: 12) {
                ForEach(viewModel.durations, id: \.self) { duration in
                    durationButton(for: duration)
                }
            }
        }
    }

    // MARK: - Duration Button

    private func durationButton(for duration: String) -> some View {

        let isSelected = viewModel.duration == duration

        return Button {
            viewModel.duration = duration
        } label: {
            Text(duration)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .foregroundStyle(
                    isSelected ? Color.white : Color.primary
                )
                .background {
                    Capsule()
                        .fill(
                            isSelected
                            ? Color.orange
                            : Color(uiColor: .secondarySystemBackground)
                        )
                }
                .overlay {
                    Capsule()
                        .stroke(
                            isSelected
                            ? Color.orange
                            : Color.secondary.opacity(0.25),
                            lineWidth: 1
                        )
                }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Continue Button

    private var continueButton: some View {
        Button {
            showActivity = true
        } label: {
            Text("Continue")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    Color.orange,
                    in: RoundedRectangle(cornerRadius: 14)
                )
        }
        .buttonStyle(.plain)
        .disabled(!viewModel.canContinue)
        .opacity(viewModel.canContinue ? 1 : 0.5)
    }
}

#Preview {
    LearningGoalView()
}
