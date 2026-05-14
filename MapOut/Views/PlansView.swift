//
//  PlansView.swift
//  MapOut
//
//  Created by Mate Javakhadze on 19.04.26.
//

import SwiftUI
import SwiftData

struct PlansView: View {
    @Query private var allPlans: [PlansModel]
    @Environment(\.modelContext) private var modelContext
    @State private var showCreateSheet = false
    @State private var showSettings = false
    @State private var selectedCategory: PlanCategory? = nil
    @State private var searchText = ""
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("userName") private var userName = ""



    var visibleCategories: [PlanCategory] {
        if let selected = selectedCategory {
            return [selected]
        }
        return PlanCategory.allCases
    }

    func plans(for category: PlanCategory) -> [PlansModel] {
        allPlans.filter { $0.categoryRaw == category.rawValue && !$0.isArchived }
    }
    
    var nextUpcomingPlan: PlansModel? {
        allPlans
            .filter { !$0.isCompleted && $0.startDate > Date() }
            .sorted { $0.startDate < $1.startDate }
            .first
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text(userName.isEmpty ? "Plans" : "Hi, \(userName)! 👋")
                            .font(.largeTitle)
                            .bold()
                            .font(.largeTitle)
                            .bold()
                        Spacer()
                        Button { showCreateSheet = true } label: {
                            Image(systemName: "plus")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(10)
                                .background(Color(.systemGray6))
                                .clipShape(Circle())
                                .foregroundStyle(Color("RoyalBlue"))
                        }
                        Button { showSettings = true } label: {
                            Image(systemName: "gear")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(10)
                                .background(Color(.systemGray6))
                                .clipShape(Circle())
                                .foregroundStyle(Color("RoyalBlue"))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)

                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        TextField("Search plans...", text: $searchText)
                        if !searchText.isEmpty {
                            Button {
                                searchText = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(32)
                    .padding(.horizontal)
                    
                    
                    if let next = nextUpcomingPlan {
                        CountdownCardView(plan: next)
                            .padding(.horizontal)
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(PlanCategory.allCases, id: \.self) { category in
                                let isSelected = selectedCategory == category
                                Button {
                                    withAnimation(.spring()) {
                                        selectedCategory = isSelected ? nil : category
                                    }
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: category.icon)
                                        Text(category.rawValue)
                                            .font(.subheadline)
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(isSelected ? category.color : Color(.systemGray6))
                                    .foregroundStyle(isSelected ? .white : .primary)
                                    .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    

                    ForEach(visibleCategories, id: \.self) { category in
                        let categoryPlans = plans(for: category)
                        if !categoryPlans.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 8) {
                                    Image(systemName: category.icon)
                                        .foregroundStyle(category.color)
                                    Text(category.rawValue)
                                        .font(.title2)
                                        .bold()
                                    Text("\(categoryPlans.count)")
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(Color(.systemGray5))
                                        .cornerRadius(10)
                                }
                                .padding(.horizontal)

                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                    ForEach(categoryPlans) { plan in
                                        PlanBoxView(
                                            plan: plan,
                                            onDelete: {
                                                NotificationManager.cancel(for: $0)
                                                modelContext.delete($0)
                                            },
                                            onToggleComplete: { p in
                                                p.isCompleted.toggle()
                                                p.completedDate = p.isCompleted ? Date() : nil
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal)

                                Divider()
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showCreateSheet) {
                CreatePlanView()
                    .preferredColorScheme(isDarkMode ? .dark : .light)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(planCount: allPlans.count)
                    .preferredColorScheme(isDarkMode ? .dark : .light)
            }
            .onAppear {
                for plan in allPlans {
                    if plan.isCompleted,
                       let completedDate = plan.completedDate,
                       Date().timeIntervalSince(completedDate) > 3 * 86400 {
                        if plan.imageData != nil || !plan.photoLog.isEmpty {
                            plan.isArchived = true
                        } else {
                            modelContext.delete(plan)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    PlansView()
        .modelContainer(for: PlansModel.self, inMemory: true)
}
