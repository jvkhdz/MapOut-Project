//
//  ShareCardView.swift
//  MapOut
//
//  Created by Mate Javakhadze on 24.04.26.
//

import SwiftUI

struct ShareCardView: View {
    let plan: PlansModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let imageData = plan.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 360, height: 180)
                    .clipped()
            }

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 6) {
                    Image(systemName: plan.category.icon)
                        .font(.caption)
                    Text(plan.category.rawValue)
                        .font(.caption)
                        .bold()
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(plan.category.color.opacity(0.2))
                .foregroundStyle(plan.category.color)
                .cornerRadius(20)

                Text(plan.title)
                    .font(.title2)
                    .bold()

                HStack(spacing: 16) {
                    Label(plan.startDate.formatted(date: .abbreviated, time: .shortened), systemImage: "calendar")
                    Label(plan.endDate.formatted(date: .abbreviated, time: .shortened), systemImage: "flag")
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                switch plan.category {
                case .trip:
                    if let airline = plan.tripAirline, !airline.isEmpty {
                        Label(airline, systemImage: "airplane").font(.caption)
                    }
                    if let hotel = plan.tripHotel, !hotel.isEmpty {
                        Label(hotel, systemImage: "building.2").font(.caption)
                    }
                case .friends:
                    if let location = plan.friendsLocation, !location.isEmpty {
                        Label(location, systemImage: "mappin.circle").font(.caption)
                    }
                    if !plan.friendsAttendees.isEmpty {
                        Label("\(plan.friendsAttendees.count) people coming", systemImage: "person.2").font(.caption)
                    }
                case .work:
                    Label("Priority: \(plan.workPriority.rawValue)", systemImage: "exclamationmark.circle").font(.caption)
                case .health:
                    Label(plan.healthType.rawValue, systemImage: "figure.run").font(.caption)
                    if let goal = plan.healthGoal, !goal.isEmpty {
                        Label(goal, systemImage: "target").font(.caption)
                    }
                default:
                    EmptyView()
                }

                Divider()

                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundStyle(.blue)
                    Text("MapOut")
                        .font(.caption)
                        .bold()
                        .foregroundStyle(.blue)
                    Spacer()
                    if plan.isCompleted {
                        Label("Completed", systemImage: "checkmark.circle.fill")
                            .font(.caption2)
                            .foregroundStyle(.green)
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
        .frame(width: 360)
    }
}


#Preview {
    ShareCardView(plan: PlansModel(title: "Paris Trip", category: .trip, startDate: Date(), endDate: Date()))
        .padding()
}
