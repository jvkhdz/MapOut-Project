//
//  CountdownCardView.swift
//  MapOut
//
//  Created by Mate Javakhadze on 29.04.26.
//

import SwiftUI
import Combine
import SwiftData

struct CountdownCardView: View {
    let plan: PlansModel
    @State private var timeRemaining: TimeInterval = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var days: Int { Int(timeRemaining) / 86400 }
    var hours: Int { (Int(timeRemaining) % 86400) / 3600 }
    var minutes: Int { (Int(timeRemaining) % 3600) / 60 }
    var seconds: Int { Int(timeRemaining) % 60 }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: plan.category.icon)
                        .font(.caption)
                    Text(plan.category.rawValue)
                        .font(.caption)
                        .bold()
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(.white.opacity(0.2))
                .cornerRadius(20)

                Spacer()

                Text("Up Next")
                    .font(.caption)
                    .bold()
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.white.opacity(0.2))
                    .cornerRadius(20)
            }
            .foregroundStyle(.white)

            Text(plan.title)
                .font(.title2)
                .bold()
                .foregroundStyle(.white)

            Label(plan.startDate.formatted(date: .abbreviated, time: .shortened), systemImage: "calendar")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.8))

            HStack(spacing: 12) {
                CountdownUnit(value: days, label: "Days")
                CountdownUnit(value: hours, label: "Hours")
                CountdownUnit(value: minutes, label: "Min")
                CountdownUnit(value: seconds, label: "Sec")
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [plan.category.color, plan.category.color.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .shadow(color: plan.category.color.opacity(0.4), radius: 12, x: 0, y: 6)
        .onAppear { updateTime() }
        .onReceive(timer) { _ in updateTime() }
    }

    func updateTime() {
        let remaining = plan.startDate.timeIntervalSince(Date())
        timeRemaining = max(remaining, 0)
    }
}

struct CountdownUnit: View {
    let value: Int
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text(String(format: "%02d", value))
                .font(.title2)
                .bold()
                .foregroundStyle(.white)
                .monospacedDigit()
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(minWidth: 44)
        .padding(.vertical, 8)
        .padding(.horizontal, 6)
        .background(.white.opacity(0.15))
        .cornerRadius(10)
    }
}

#Preview {
    CountdownCardView(
        plan: PlansModel(
            title: "Paris Trip",
            category: .trip,
            startDate: Date().addingTimeInterval(86400 * 3),
            endDate: Date().addingTimeInterval(86400 * 7)
        )
    )
    .modelContainer(for: PlansModel.self, inMemory: true)
    .padding()
}
