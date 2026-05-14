//
//  EditPlanView.swift
//  MapOut
//
//  Created by Mate Javakhadze on 21.04.26.
//

import SwiftUI
import SwiftData
import PhotosUI



struct EditPlanView: View {
    @Environment(\.dismiss) private var dismiss
    let plan: PlansModel

    @State private var photoItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data?
    
    @State private var title: String
    @State private var category: PlanCategory
    @State private var startDate: Date
    @State private var endDate: Date

    @State private var tripBudget: String
    @State private var tripAirline: String
    @State private var tripHotel: String
    @State private var tripPackingItem = ""
    @State private var tripPackingList: [String]

    @State private var workPriority: WorkPriority
    @State private var workNotes: String

    @State private var friendsLocation: String
    @State private var friendsAttendeeInput = ""
    @State private var friendsAttendees: [String]

    @State private var healthType: HealthType
    @State private var healthGoal: String
    @State private var healthFrequency: String

    @State private var otherNotes: String
    
    @State private var momentCaptureEnabled: Bool

    init(plan: PlansModel) {
        self.plan = plan
        _title = State(initialValue: plan.title)
        _category = State(initialValue: plan.category)
        _startDate = State(initialValue: plan.startDate)
        _endDate = State(initialValue: plan.endDate)
        _tripBudget = State(initialValue: plan.tripBudget.map { String($0) } ?? "")
        _tripAirline = State(initialValue: plan.tripAirline ?? "")
        _tripHotel = State(initialValue: plan.tripHotel ?? "")
        _tripPackingList = State(initialValue: plan.tripPackingList)
        _workPriority = State(initialValue: plan.workPriority)
        _workNotes = State(initialValue: plan.workNotes ?? "")
        _friendsLocation = State(initialValue: plan.friendsLocation ?? "")
        _friendsAttendees = State(initialValue: plan.friendsAttendees)
        _healthType = State(initialValue: plan.healthType)
        _healthGoal = State(initialValue: plan.healthGoal ?? "")
        _healthFrequency = State(initialValue: plan.healthFrequency ?? "")
        _otherNotes = State(initialValue: plan.otherNotes ?? "")
        _selectedImageData = State(initialValue: plan.imageData)
        _momentCaptureEnabled = State(initialValue: plan.momentCaptureEnabled)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Title", text: $title)
                    Picker("Category", selection: $category) {
                        ForEach(PlanCategory.allCases, id: \.self) { cat in
                            Label(cat.rawValue, systemImage: cat.icon).tag(cat)
                        }
                    }
                }

                Section("Dates") {
                    DatePicker("Start", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                    DatePicker("End", selection: $endDate, in: startDate..., displayedComponents: [.date, .hourAndMinute])
                }

                if category == .trip {
                    Section("Trip Details") {
                        TextField("Airline", text: $tripAirline)
                        TextField("Hotel", text: $tripHotel)
                        HStack {
                            Text("Budget")
                            Spacer()
                            TextField("0.00", text: $tripBudget)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    Section("Packing List") {
                        ForEach(tripPackingList, id: \.self) { item in
                            HStack {
                                Image(systemName: "checkmark.circle").foregroundStyle(.green)
                                Text(item)
                            }
                        }
                        .onDelete { tripPackingList.remove(atOffsets: $0) }
                        HStack {
                            TextField("Add item...", text: $tripPackingItem)
                            Button {
                                guard !tripPackingItem.isEmpty else { return }
                                tripPackingList.append(tripPackingItem)
                                tripPackingItem = ""
                            } label: {
                                Image(systemName: "plus.circle.fill").foregroundStyle(.blue)
                            }
                        }
                    }
                }

                if category == .work {
                    Section("Work Details") {
                        Picker("Priority", selection: $workPriority) {
                            ForEach(WorkPriority.allCases, id: \.self) { p in
                                Text(p.rawValue).tag(p)
                            }
                        }
                        .pickerStyle(.segmented)
                        TextField("Notes", text: $workNotes, axis: .vertical)
                            .lineLimit(3...6)
                    }
                }

                if category == .friends {
                    Section("Friends Details") {
                        TextField("Location", text: $friendsLocation)
                    }
                    Section("Who's Coming") {
                        ForEach(friendsAttendees, id: \.self) { person in
                            HStack {
                                Image(systemName: "person.circle.fill").foregroundStyle(.green)
                                Text(person)
                            }
                        }
                        .onDelete { friendsAttendees.remove(atOffsets: $0) }
                        HStack {
                            TextField("Add person...", text: $friendsAttendeeInput)
                            Button {
                                guard !friendsAttendeeInput.isEmpty else { return }
                                friendsAttendees.append(friendsAttendeeInput)
                                friendsAttendeeInput = ""
                            } label: {
                                Image(systemName: "plus.circle.fill").foregroundStyle(.green)
                            }
                        }
                    }
                }

                if category == .health {
                    Section("Health Details") {
                        Picker("Type", selection: $healthType) {
                            ForEach(HealthType.allCases, id: \.self) { t in
                                Text(t.rawValue).tag(t)
                            }
                        }
                        .pickerStyle(.segmented)
                        TextField("Goal", text: $healthGoal)
                        TextField("Frequency (e.g. 3x per week)", text: $healthFrequency)
                    }
                }

                if category == .other {
                    Section("Notes") {
                        TextField("Notes", text: $otherNotes, axis: .vertical)
                            .lineLimit(3...6)
                    }
                }
            }
            .navigationTitle("Edit Plan")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        plan.title = title
                        plan.category = category
                        plan.startDate = startDate
                        plan.endDate = endDate
                        plan.tripAirline = tripAirline.isEmpty ? nil : tripAirline
                        plan.tripHotel = tripHotel.isEmpty ? nil : tripHotel
                        plan.tripBudget = Double(tripBudget)
                        plan.tripPackingList = tripPackingList
                        plan.workPriority = workPriority
                        plan.workNotes = workNotes.isEmpty ? nil : workNotes
                        plan.friendsLocation = friendsLocation.isEmpty ? nil : friendsLocation
                        plan.friendsAttendees = friendsAttendees
                        plan.imageData = selectedImageData
                        plan.healthType = healthType
                        plan.healthGoal = healthGoal.isEmpty ? nil : healthGoal
                        plan.healthFrequency = healthFrequency.isEmpty ? nil : healthFrequency
                        plan.otherNotes = otherNotes.isEmpty ? nil : otherNotes
                        NotificationManager.cancel(for: plan)
                        NotificationManager.schedule(for: plan)
                        plan.momentCaptureEnabled = momentCaptureEnabled
                        MomentNotificationManager.cancelMoments(for: plan)
                        MomentNotificationManager.scheduleRandomMoments(for: plan)
                        if endDate < startDate {
                            endDate = startDate.addingTimeInterval(3600)
                        }
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

#Preview {
    EditPlanView(plan: PlansModel(title: "Walk Dog", category: .personal, startDate: Date(), endDate: Date()))
        .modelContainer(for: PlansModel.self, inMemory: true)
}
