//
//  CalendarView.swift
//  MapOut
//
//  Created by Mate Javakhadze on 21.04.26.
//

import SwiftUI
import SwiftData

struct CalendarView: View {
    @Query private var allPlans: [PlansModel]
    @State private var selectedDate: Date = Date()
    @State private var currentMonth: Date = Date()
    @StateObject private var weatherService = WeatherService()
    @State private var weatherLocation = "your city"

    var calendar: Calendar { Calendar.current }

    var daysInMonth: [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: currentMonth),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))
        else { return [] }

        let weekday = calendar.component(.weekday, from: firstDay)
        let offset = (weekday - calendar.firstWeekday + 7) % 7
        var days: [Date?] = Array(repeating: nil, count: offset)
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(date)
            }
        }
        return days
    }

    func plans(on date: Date) -> [PlansModel] {
        allPlans.filter { calendar.isDate($0.startDate, inSameDayAs: date) }
    }

    func hasPlans(on date: Date) -> Bool {
        !plans(on: date).isEmpty
    }

    var selectedPlans: [PlansModel] {
        plans(on: selectedDate)
    }

    var monthTitle: String {
        currentMonth.formatted(.dateTime.month(.wide).year())
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    HStack {
                        Button {
                            withAnimation {
                                currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                            }
                        } label: {
                            Image(systemName: "chevron.left")
                                .padding(8)
                                .background(Color(.systemGray6))
                                .clipShape(Circle())
                        }
                        Spacer()
                        Text(monthTitle)
                            .font(.title2)
                            .bold()
                        Spacer()
                        Button {
                            withAnimation {
                                currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                            }
                        } label: {
                            Image(systemName: "chevron.right")
                                .padding(8)
                                .background(Color(.systemGray6))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal)

                    HStack {
                        ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                            Text(day)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                        ForEach(Array(daysInMonth.enumerated()), id: \.offset) { _, date in
                            if let date = date {
                                let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                                let isToday = calendar.isDateInToday(date)
                                let hasPlans = hasPlans(on: date)

                                Button {
                                    withAnimation { selectedDate = date }
                                } label: {
                                    VStack(spacing: 4) {
                                        Text("\(calendar.component(.day, from: date))")
                                            .font(.subheadline)
                                            .fontWeight(isToday ? .bold : .regular)
                                            .foregroundStyle(isSelected ? .white : isToday ? .blue : .primary)
                                            .frame(width: 36, height: 36)
                                            .background(isSelected ? Color.blue : Color.clear)
                                            .clipShape(Circle())

                                        // Dot if has plans
                                        Circle()
                                            .fill(hasPlans ? Color.blue : Color.clear)
                                            .frame(width: 5, height: 5)
                                    }
                                }
                            } else {
                                Color.clear.frame(height: 44)
                            }
                        }
                    }
                    .padding(.horizontal)

                    Divider()

                    VStack(alignment: .leading, spacing: 12) {
                        Text(selectedDate.formatted(.dateTime.weekday(.wide).month().day()))
                            .font(.headline)
                            .padding(.horizontal)

                        if selectedPlans.isEmpty {
                            VStack(spacing: 8) {
                                Image(systemName: "calendar.badge.checkmark")
                                    .font(.largeTitle)
                                    .foregroundStyle(.secondary)
                                Text("No plans this day")
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 20)
                        } else {
                            ForEach(selectedPlans) { plan in
                                NavigationLink(destination: PlanDetailView(plan: plan, onDelete: { _ in })) {
                                    HStack(spacing: 12) {
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(plan.category.color)
                                            .frame(width: 4)
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(plan.title)
                                                .font(.subheadline)
                                                .bold()
                                                .foregroundStyle(.primary)
                                            Text(plan.startDate, style: .time)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                        Image(systemName: plan.category.icon)
                                            .foregroundStyle(plan.category.color)
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                                    .padding(.horizontal)
                                }
                            }
                        }
                        
                        if !selectedPlans.isEmpty {
                            WeatherCardView(
                                location: selectedPlans.first?.friendsLocation ?? selectedPlans.first?.tripHotel ?? "your city",
                                date: selectedDate
                            )
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.top)
                
                
            }
            .navigationTitle("Calendar")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    CalendarView()
        .modelContainer(for: PlansModel.self, inMemory: true)
}
