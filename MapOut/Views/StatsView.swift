//
//  StatsView.swift
//  MapOut
//
//  Created by Mate Javakhadze on 24.04.26.
//

import SwiftUI
import SwiftData
import Charts

struct StatsView: View {
    @Query private var allPlans: [PlansModel]
    @AppStorage("isDarkMode") private var isDarkMode = false

    var completedPlans: [PlansModel] { allPlans.filter { $0.isCompleted } }
    var activePlans: [PlansModel] { allPlans.filter { !$0.isCompleted && !$0.isArchived } }

    var completionRate: Double {
        guard !allPlans.isEmpty else { return 0 }
        return Double(completedPlans.count) / Double(allPlans.count) * 100
    }

    var mostUsedCategory: PlanCategory? {
        let counts = Dictionary(grouping: allPlans, by: { $0.category })
        return counts.max(by: { $0.value.count < $1.value.count })?.key
    }

    var plansPerCategory: [(category: PlanCategory, count: Int)] {
        PlanCategory.allCases.map { category in
            (category, allPlans.filter { $0.categoryRaw == category.rawValue }.count)
        }.filter { $0.count > 0 }
    }

    var plansThisWeek: Int {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return allPlans.filter { $0.startDate >= weekAgo }.count
    }

    var currentStreak: Int {
        var streak = 0
        var date = Calendar.current.startOfDay(for: Date())
        while true {
            let plansOnDay = completedPlans.filter {
                Calendar.current.isDate($0.completedDate ?? Date.distantPast, inSameDayAs: date)
            }
            if plansOnDay.isEmpty { break }
            streak += 1
            date = Calendar.current.date(byAdding: .day, value: -1, to: date) ?? date
        }
        return streak
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        StatCard(
                            title: "Total Plans",
                            value: "\(allPlans.count)",
                            icon: "list.bullet",
                            color: .blue
                        )
                        StatCard(
                            title: "Completed",
                            value: "\(completedPlans.count)",
                            icon: "checkmark.circle.fill",
                            color: .green
                        )
                        StatCard(
                            title: "Active",
                            value: "\(activePlans.count)",
                            icon: "clock.fill",
                            color: .orange
                        )
                        StatCard(
                            title: "This Week",
                            value: "\(plansThisWeek)",
                            icon: "calendar.badge.plus",
                            color: .purple
                        )
                    }
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Completion Rate")
                            .font(.headline)

                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray5))
                                .frame(height: 16)
                            GeometryReader { geo in
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.green)
                                    .frame(width: geo.size.width * (completionRate / 100), height: 16)
                                    .animation(.easeInOut, value: completionRate)
                            }
                            .frame(height: 16)
                        }

                        Text("\(Int(completionRate))% of plans completed")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    .padding(.horizontal)

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Current Streak")
                                .font(.headline)
                            Text("Days with completed plans")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        HStack(spacing: 4) {
                            Text("\(currentStreak)")
                                .font(.largeTitle)
                                .bold()
                            Text("🔥")
                                .font(.largeTitle)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    .padding(.horizontal)

                    if let top = mostUsedCategory {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Most Used Category")
                                    .font(.headline)
                                Text("You plan this the most")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            HStack(spacing: 8) {
                                Image(systemName: top.icon)
                                    .foregroundStyle(top.color)
                                Text(top.rawValue)
                                    .font(.headline)
                                    .bold()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(top.color.opacity(0.15))
                            .cornerRadius(12)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }

                    if !plansPerCategory.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Plans by Category")
                                .font(.headline)

                            Chart(plansPerCategory, id: \.category) { item in
                                BarMark(
                                    x: .value("Category", item.category.rawValue),
                                    y: .value("Count", item.count)
                                )
                                .foregroundStyle(item.category.color)
                                .cornerRadius(6)
                            }
                            .frame(height: 200)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
            }
            .navigationTitle("Stats")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Spacer()
            }
            Text(value)
                .font(.largeTitle)
                .bold()
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

#Preview {
    StatsView()
        .modelContainer(for: PlansModel.self, inMemory: true)
}
