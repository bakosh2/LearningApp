import SwiftUI

struct GoalEditSheet: View {
    @State private var subject: String
    @State private var duration: String
    @State private var showEmptyAlert = false
    @State private var showUpdateAlert = false
    @FocusState private var subjectIsFocused: Bool

    @Environment(\.dismiss) private var dismiss

    private let originalSubject: String
    private let originalDuration: String
    private let onSave: (String, String) -> Void
    private let durations = ["Week", "Month", "Year"]

    init(subject: String, duration: String, onSave: @escaping (String, String) -> Void) {
        _subject = State(initialValue: subject)
        _duration = State(initialValue: duration)
        originalSubject = subject
        originalDuration = duration
        self.onSave = onSave
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                header

                VStack(alignment: .leading, spacing: 0) {
                    Text("I want to learn")
                        .font(GoalFormStyle.label)
                        .padding(.top, 38)

                    TextField("What do you want to learn?", text: $subject)
                        .font(GoalFormStyle.field)
                        .textInputAutocapitalization(.sentences)
                        .focused($subjectIsFocused)
                        .padding(.vertical, 14)
                        .overlay(alignment: .bottom) {
                            Rectangle()
                                .fill(Color(uiColor: .separator).opacity(0.4))
                                .frame(height: 0.5)
                        }

                    Text("I want to learn it in a")
                        .font(GoalFormStyle.label)
                        .padding(.top, 28)
                        .padding(.bottom, 12)

                    HStack(spacing: GoalFormStyle.optionSpacing) {
                        ForEach(durations, id: \.self) { option in
                            durationButton(option, selected: duration == option)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, GoalFormStyle.horizontalPadding)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(Color(uiColor: .systemBackground))
            }
            .background(Color(uiColor: .systemBackground))

            if showUpdateAlert {
                Color.black.opacity(0.38)
                    .ignoresSafeArea()
                    .transition(.opacity)

                updateConfirmation
                    .transition(.scale(scale: 0.96).combined(with: .opacity))
            }
        }
        .background(Color(uiColor: .systemBackground))
        .onAppear { subjectIsFocused = true }
        .alert("Learning goal is empty", isPresented: $showEmptyAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please enter what you want to learn.")
        }
        .tint(.orange)
    }

    private var updateConfirmation: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Update goal")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)

            Text("If you update now, your streak will start over.")
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(.white.opacity(0.92))
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 8)

            HStack(spacing: 10) {
                Button("Dismiss") {
                    showUpdateAlert = false
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color(red: 0.20, green: 0.20, blue: 0.20), in: Capsule())

                Button("Update") {
                    showUpdateAlert = false
                    onSave(subject, duration)
                    dismiss()
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(.orange, in: Capsule())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .frame(width: 316, height: 210)
        .background(Color(red: 0.12, green: 0.12, blue: 0.12), in: RoundedRectangle(cornerRadius: 28))
        .overlay(RoundedRectangle(cornerRadius: 28).stroke(Color.white.opacity(0.10), lineWidth: 1))
    }

    private var header: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 19, weight: .medium))
                    .foregroundStyle(.primary)
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .accessibilityLabel("Back")

            Spacer()
            Text("Learning Goal")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.primary)
            Spacer()

            Button(action: save) {
                Image(systemName: "checkmark")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(.orange, in: Circle())
            }
            .accessibilityLabel("Save learning goal")
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private func durationButton(_ option: String, selected: Bool) -> some View {
        Button(option) { duration = option }
            .font(GoalFormStyle.option)
            .foregroundStyle(selected ? Color.white : Color.secondary)
            .padding(.horizontal, GoalFormStyle.optionPadding)
            .frame(height: GoalFormStyle.optionHeight)
            .background {
                if selected {
                    Capsule().fill(Color.orange)
                } else {
                    Capsule().fill(.ultraThinMaterial)
                }
            }
    }

    private func save() {
        guard !subject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showEmptyAlert = true
            return
        }

        guard subject != originalSubject || duration != originalDuration else {
            dismiss()
            return
        }

        showUpdateAlert = true
    }
}
