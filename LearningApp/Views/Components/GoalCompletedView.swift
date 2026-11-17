import SwiftUI

struct GoalCompletedView: View {
    let isSuccessful: Bool
    let onSetNewGoal: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Spacer()
            Image(systemName: isSuccessful ? "hands.and.sparkles" : "xmark.seal")
                .font(.system(size: 38, weight: .medium))
                .foregroundStyle(.orange)
            Text(isSuccessful ? "Well done!" : "You didn't reach your goal this time.")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.primary)
            Text(isSuccessful ? "Ready for your next goal?" : "Want to set another goal?")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
            Spacer()
            Button(action: onSetNewGoal) {
                Text("Set a goal")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 130, height: 36)
            }
            .buttonStyle(.glassProminent)
            .tint(.orange)
            .frame(maxWidth: .infinity)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemBackground))
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
    }
}
