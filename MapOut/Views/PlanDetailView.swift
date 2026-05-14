//
//  PlanDetailView.swift
//  MapOut
//
//  Created by Mate Javakhadze on 21.04.26.
//


import SwiftUI
import SwiftData
import PhotosUI

struct PlanDetailView: View {
    let plan: PlansModel
    let onDelete: (PlansModel) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var showEdit = false
    
    @State private var shareImage: UIImage? = nil
    @State private var showShareSheet = false
    
    @State private var openCameraFromNotification = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {


                VStack(alignment: .leading, spacing: 8) {
                    if let imageData = plan.imageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    HStack {
                        Image(systemName: plan.category.icon)
                            .font(.title2)
                            .foregroundStyle(plan.category.color)
                        Text(plan.category.rawValue)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        if plan.isCompleted {
                            Label("Completed", systemImage: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundStyle(.green)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(.green.opacity(0.15))
                                .cornerRadius(20)
                        }
                    }

                    Text(plan.title)
                        .font(.largeTitle)
                        .bold()

                    HStack(spacing: 16) {
                        Label(plan.startDate.formatted(date: .abbreviated, time: .shortened), systemImage: "calendar")
                        Label(plan.endDate.formatted(date: .abbreviated, time: .shortened), systemImage: "flag")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(plan.category.color.opacity(0.15))
                .cornerRadius(16)


                switch plan.category {
                case .trip:     tripSection
                case .work:     workSection
                case .friends:  friendsSection
                case .health:   healthSection
                case .other:    otherSection
                case .personal: EmptyView()
                }
                
                PhotoLogView(plan: plan)
                    .padding(.horizontal)
            }
            .sheet(isPresented: $showShareSheet) {
                if let image = shareImage {
                    ShareSheet(items: [image])
                }
            }
            .sheet(isPresented: $showEdit) {
                EditPlanView(plan: plan)
            }
            .padding()
            .onReceive(NotificationCenter.default.publisher(for: .openMomentCapture)) { notification in
                if let planID = notification.userInfo?["planID"] as? String,
                   planID == plan.id {
                    openCameraFromNotification = true
                }
            }
            .sheet(isPresented: $openCameraFromNotification) {
                MomentCameraView { image in
                    if let data = image.jpegData(compressionQuality: 0.8) {
                        plan.photoLog.append(data)
                    }
                    openCameraFromNotification = false
                }
            }
        }
        .navigationTitle(plan.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack {
                    Button {
                        shareImage = ShareHelper.renderCard(plan: plan)
                        showShareSheet = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                    Button {
                        showEdit = true
                    } label: {
                        Image(systemName: "pencil")
                    }
                }
            }
            ToolbarItem(placement: .destructiveAction) {
                Button(role: .destructive) {
                    onDelete(plan)
                    dismiss()
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(.red)
                }
            }
        }
    }

    @ViewBuilder
    var tripSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Trip Details").font(.title3).bold()
            if let airline = plan.tripAirline, !airline.isEmpty {
                DetailRow(icon: "airplane", label: "Airline", value: airline)
            }
            if let hotel = plan.tripHotel, !hotel.isEmpty {
                DetailRow(icon: "building.2", label: "Hotel", value: hotel)
            }
            if let airline = plan.tripAirline, !airline.isEmpty {
                let destination = plan.tripHotel ?? plan.tripAirline ?? ""
                if !destination.isEmpty {
                    WeatherCardView(location: destination, date: plan.startDate)
                }
            }
            if let budget = plan.tripBudget {
                DetailRow(icon: "dollarsign.circle", label: "Budget", value: String(format: "$%.2f", budget))
            }
            if !plan.tripPackingList.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Packing List", systemImage: "checklist").font(.subheadline).bold()
                    ForEach(plan.tripPackingList, id: \.self) { item in
                        HStack {
                            Image(systemName: "circle").font(.caption).foregroundStyle(.secondary)
                            Text(item).font(.subheadline)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
    }

    @ViewBuilder
    var workSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Work Details").font(.title3).bold()
            DetailRow(icon: "exclamationmark.circle", label: "Priority", value: plan.workPriority.rawValue)
            if let notes = plan.workNotes, !notes.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Label("Notes", systemImage: "note.text").font(.subheadline).bold()
                    Text(notes).font(.subheadline).foregroundStyle(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
    }

    @ViewBuilder
    var friendsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Friends Details").font(.title3).bold()
            if let location = plan.friendsLocation, !location.isEmpty {
                DetailRow(icon: "mappin.circle", label: "Location", value: location)
            }
            if !plan.friendsAttendees.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Who's Coming", systemImage: "person.2").font(.subheadline).bold()
                    ForEach(plan.friendsAttendees, id: \.self) { person in
                        HStack {
                            Image(systemName: "person.circle.fill").foregroundStyle(.green)
                            Text(person).font(.subheadline)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            if let location = plan.friendsLocation, !location.isEmpty {
                DetailRow(icon: "mappin.circle", label: "Location", value: location)
                WeatherCardView(location: location, date: plan.startDate)
            }
        }
    }

    @ViewBuilder
    var healthSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Health Details").font(.title3).bold()
            DetailRow(icon: "figure.run", label: "Type", value: plan.healthType.rawValue)
            if let goal = plan.healthGoal, !goal.isEmpty {
                DetailRow(icon: "target", label: "Goal", value: goal)
            }
            if let frequency = plan.healthFrequency, !frequency.isEmpty {
                DetailRow(icon: "repeat", label: "Frequency", value: frequency)
            }
        }
    }

    @ViewBuilder
    var otherSection: some View {
        if let notes = plan.otherNotes, !notes.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Notes").font(.title3).bold()
                Text(notes).font(.subheadline).foregroundStyle(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

struct DetailRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack {
            Label(label, systemImage: icon)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .bold()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    NavigationStack {
        PlanDetailView(
            plan: PlansModel(title: "Paris Trip", category: .trip, startDate: Date(), endDate: Date()),
            onDelete: { _ in }
        )
    }
    .modelContainer(for: PlansModel.self, inMemory: true)
}
