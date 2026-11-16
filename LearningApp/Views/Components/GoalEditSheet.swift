
import SwiftUI

struct GoalEditSheet: View {

    @State private var subject: String
    @State private var duration: String

    @State private var showEmptyAlert = false

    @Environment(\.dismiss) private var dismiss

    let onSave: (String, String) -> Void

    init(
        subject: String,
        duration: String,
        onSave: @escaping (String, String) -> Void
    ) {
        _subject = State(initialValue: subject)
        _duration = State(initialValue: duration)
        self.onSave = onSave
    }

    var body: some View {

        NavigationStack {

            VStack(alignment: .leading, spacing: 25) {

                Text("I want to learn")
                    .font(.system(size: 16))
                    .foregroundStyle(.primary)

                TextField(
                    "What do you want to learn?",
                    text: $subject
                )
                .font(.system(size: 16))
                .padding(.vertical, 12)
                .textInputAutocapitalization(.sentences)

                Rectangle()
                    .fill(Color(uiColor: .separator))
                    .frame(height: 1)

                Text("I want to learn it in a")
                    .font(.system(size: 16))
                    .foregroundStyle(.primary)

                HStack(spacing: 12) {
                    durationButton("Week")
                    durationButton("Month")
                    durationButton("Year")
                }

                Spacer()
            }
            .padding(20)
            .navigationTitle("Learning Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {

                ToolbarItem(placement: .confirmationAction) {

                    Button {

                        if subject.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ).isEmpty {

                            showEmptyAlert = true

                        } else {

                            onSave(subject, duration)
                            dismiss()
                        }

                    } label: {

                        Image(systemName: "checkmark")
                    }
                    .buttonStyle(.glassProminent)
                    .tint(.orange)
                }
            }
            .alert(
                "Learning goal is empty",
                isPresented: $showEmptyAlert
            ) {

                Button("OK", role: .cancel) { }

            } message: {

                Text("Please enter what you want to learn.")
            }
        }
    }

    private func durationButton(_ title: String) -> some View {

        let isSelected = duration == title

        return Button {

            duration = title

        } label: {

            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(
                    isSelected ? .white : .primary
                )
                .frame(width: 85, height: 44)
                .background {

                    if isSelected {

                        Capsule()
                            .fill(Color.orange)

                    } else {

                        Capsule()
                            .fill(.ultraThinMaterial)
                            .overlay {

                                Capsule()
                                    .stroke(
                                        Color(uiColor: .separator).opacity(0.4),
                                        lineWidth: 1
                                    )
                            }
                    }
                }
        }
        .buttonStyle(.plain)
        .buttonStyle(.borderedProminent)
        .tint(.orange)
    }

}
