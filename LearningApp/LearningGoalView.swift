

import SwiftUI
struct LearningGoalView: View {
    
    let accentColor = Color(
        red: 1.0,
        green: 146.0 / 255.0,
        blue: 48.0 / 255.0
    )
    
    @State private var selectedDuration = "Week"
    @State private var learningSubject = ""
    var body: some View {
        
        ZStack {
            
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                
                Image(systemName: "flame.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(accentColor)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                
                
                Spacer()
                    .frame(height: 82)
                
                
                
                HStack(spacing: 5) {
                    
                    Text("Hello")
                        .fontWeight(.regular)
                    
                    Text("Learner")
                        .fontWeight(.bold)
                }
                .font(.system(size: 32))
                .foregroundStyle(.primary)
                
                
                Text("This app will help you learn everyday!")
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
                
                
                Spacer()
                    .frame(height: 36)
                
                
                Text("I want to learn")
                    .font(.system(size: 16))
                    .foregroundStyle(.primary)
                
                TextField(
                    "Swift",
                    text: $learningSubject
                )
                .font(.system(size: 16))
                .foregroundStyle(.primary)
                .padding(.top, 18)
                .textInputAutocapitalization(.sentences)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.35))
                    .frame(height: 1)
                    .padding(.top, 14)
                
                
                Spacer()
                    .frame(height: 29)
                
                
                
                Text("I want to learn it in a")
                    .font(.system(size: 16))
                    .foregroundStyle(.primary)
                
                
                HStack(spacing: 10) {
                    
                    durationButton("Week")
                    
                    durationButton("Month")
                    
                    durationButton("Year")
                }
                .padding(.top, 4)
                .padding(.horizontal, -1)
                .padding(.vertical, 8)
                
                
                Spacer()
                
                Button {
                    
                    print("Subject: \(learningSubject)")
                    print("Duration: \(selectedDuration)")
                    
                } label: {
                    
                    Text("Start Learning")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .frame(height: 48)
                    
                }
                .buttonStyle(.glassProminent)
                .tint(accentColor)
                .frame(maxWidth: .infinity)
                
                
                
                Text("You can edit your desire later")
                    .font(.system(size: 14))
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 12)
                    .padding(.bottom, 18)
            }
            .padding(.horizontal, 18)
        }
        
    }
    
    @ViewBuilder
    func durationButton(_ title: String) -> some View {
        
        let isSelected = selectedDuration == title
        
        if isSelected {
            
            Button {
                selectedDuration = title
            } label: {
                Text(title)
                    .font(.system(size: 18))
                    .frame(width: 75, height: 36)
            }
            .buttonStyle(.glassProminent)
            .tint(accentColor)
            
        } else {
            
            Button {
                selectedDuration = title
            } label: {
                Text(title)
                    .font(.system(size: 18))
                    .frame(width: 75, height: 36)
            }
            .buttonStyle(.glass)
            .tint(Color.secondary)
        }
    }
}
#Preview {
    LearningGoalView()
}

