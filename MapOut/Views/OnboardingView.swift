//
//  OnboardingView.swift
//  MapOut
//
//  Created by Mate Javakhadze on 28.04.26.
//

import SwiftUI
import SwiftData

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @Environment(\.modelContext) private var modelContext
    @State private var currentStep = 0
    @State private var name = ""
    @State private var selectedCategory: PlanCategory = .personal
    @State private var planTitle = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(3600)

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color.blue.opacity(0.8), Color.indigo],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress dots
                HStack(spacing: 8) {
                    ForEach(0..<4) { i in
                        Circle()
                            .fill(i == currentStep ? .white : .white.opacity(0.3))
                            .frame(width: i == currentStep ? 10 : 7, height: i == currentStep ? 10 : 7)
                            .animation(.spring(), value: currentStep)
                    }
                }
                .padding(.top, 60)

                Spacer()

                // Step content
                Group {
                    switch currentStep {
                    case 0: stepWelcome
                    case 1: stepName
                    case 2: stepCategory
                    case 3: stepCreatePlan
                    default: EmptyView()
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .id(currentStep)

                Spacer()

                // Next button
                Button {
                    withAnimation(.spring()) {
                        if currentStep < 3 {
                            currentStep += 1
                        } else {
                            finishOnboarding()
                        }
                    }
                } label: {
                    Text(currentStep == 3 ? "Let's Go 🚀" : "Continue")
                        .font(.headline)
                        .foregroundStyle(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.white)
                        .cornerRadius(16)
                }
                .disabled(nextButtonDisabled)
                .opacity(nextButtonDisabled ? 0.5 : 1)
                .padding(.horizontal, 32)
                .padding(.bottom, 50)
            }
        }
    }

    var nextButtonDisabled: Bool {
        switch currentStep {
        case 1: return name.trimmingCharacters(in: .whitespaces).isEmpty
        case 3: return planTitle.trimmingCharacters(in: .whitespaces).isEmpty
        default: return false
        }
    }

    // MARK: - Steps

    var stepWelcome: some View {
        VStack(spacing: 24) {
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.2), radius: 10)

            VStack(spacing: 12) {
                Text("Welcome to MapOut")
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(.white)
                Text("Plan your life, one step at a time.\nLet's get you set up in 3 quick steps.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, 32)
    }

    var stepName: some View {
        VStack(spacing: 24) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.white)

            VStack(spacing: 12) {
                Text("What's your name?")
                    .font(.title)
                    .bold()
                    .foregroundStyle(.white)
                Text("We'll use this to personalize your experience.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }

            TextField("Your name", text: $name)
                .padding()
                .background(.white.opacity(0.2))
                .cornerRadius(12)
                .foregroundStyle(.white)
                .tint(.white)
        }
        .padding(.horizontal, 32)
    }

    var stepCategory: some View {
        VStack(spacing: 24) {
            Image(systemName: "square.grid.2x2.fill")
                .font(.system(size: 60))
                .foregroundStyle(.white)

            VStack(spacing: 12) {
                Text("What do you plan most?")
                    .font(.title)
                    .bold()
                    .foregroundStyle(.white)
                Text("Pick your main focus — you can always use others.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(PlanCategory.allCases, id: \.self) { category in
                    let isSelected = selectedCategory == category
                    Button {
                        withAnimation(.spring()) {
                            selectedCategory = category
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: category.icon)
                            Text(category.rawValue)
                                .font(.subheadline)
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(isSelected ? .white : .white.opacity(0.15))
                        .foregroundStyle(isSelected ? .blue : .white)
                        .cornerRadius(12)
                    }
                }
            }
        }
        .padding(.horizontal, 32)
    }

    var stepCreatePlan: some View {
        VStack(spacing: 24) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.white)

            VStack(spacing: 12) {
                Text("Create your first plan")
                    .font(.title)
                    .bold()
                    .foregroundStyle(.white)
                Text("Let's create a \(selectedCategory.rawValue.lowercased()) plan to get started.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 12) {
                TextField("Plan title", text: $planTitle)
                    .padding()
                    .background(.white.opacity(0.2))
                    .cornerRadius(12)
                    .foregroundStyle(.white)
                    .tint(.white)

                DatePicker("Start", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                    .padding()
                    .background(.white.opacity(0.2))
                    .cornerRadius(12)
                    .foregroundStyle(.white)
                    .tint(.white)
                    .colorScheme(.dark)

                DatePicker("End", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                    .padding()
                    .background(.white.opacity(0.2))
                    .cornerRadius(12)
                    .foregroundStyle(.white)
                    .tint(.white)
                    .colorScheme(.dark)
            }
        }
        .padding(.horizontal, 32)
    }

    func finishOnboarding() {
        UserDefaults.standard.set(name, forKey: "userName")

        if !planTitle.isEmpty {
            let plan = PlansModel(
                title: planTitle,
                category: selectedCategory,
                startDate: startDate,
                endDate: endDate
            )
            modelContext.insert(plan)
            try? modelContext.save()
            NotificationManager.schedule(for: plan)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            hasCompletedOnboarding = true
        }
    }
}

#Preview {
    OnboardingView()
        .modelContainer(for: PlansModel.self, inMemory: true)
}
