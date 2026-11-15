
import SwiftUI

struct OnboardingView: View {

    @State private var currentPage = 0
 @State private var showLearnungGoal = false
    let accentColor = Color(
        .orange)

    var body: some View {

        ZStack {

            Color(uiColor: .systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 20) {

                Image("onboarding_image")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)

                Image(systemName: "flame.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(accentColor)

                // Title
                if currentPage == 0 {
                    Text("Hello Learner")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)

                } else if currentPage == 1 {
                    Text("Learn Something New")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)

                } else {
                    Text("Ready to Start?")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                }

                Spacer()

                
                if currentPage == 0 {
                    Text("Start your learning journey")
                        .font(.title3)
                        .foregroundStyle(.secondary)

                } else if currentPage == 1 {
                    Text("Explore new skills and knowledge")
                        .font(.title3)
                        .foregroundStyle(.secondary)

                } else {
                    Text("Let's begin your journey today")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                Spacer()

               
                HStack(spacing: 8) {

                    Circle()
                        .fill(currentPage == 0 ? accentColor : Color.gray.opacity(0.3))
                        .frame(width: 10, height: 10)

                    Circle()
                        .fill(currentPage == 1 ? accentColor : Color.gray.opacity(0.3))
                        .frame(width: 10, height: 10)

                    Circle()
                        .fill(currentPage == 2 ? accentColor : Color.gray.opacity(0.3))
                        .frame(width: 10, height: 10)
                }

              
                Button("Continue") {

                    if currentPage < 2 {
                        currentPage += 1
                    }
                    
                    else{
                        showLearnungGoal = true
                    }
                }
                .font(.headline)
                .foregroundStyle(.black)
                .padding()
                .frame(maxWidth: .infinity)
                .frame(height: 55)
                .background(accentColor)
                .cornerRadius(16)
                .shadow(
                    color: accentColor.opacity(0.3),
                    radius: 8,
                    x: 0,
                    y: 4
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.top, 60)
            .padding(.horizontal, 24)
        }
        
        .navigationDestination(isPresented: $showLearnungGoal) {
            LearningGoalView()
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    OnboardingView()
}
