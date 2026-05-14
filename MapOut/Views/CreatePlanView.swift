import SwiftUI
import SwiftData
import PhotosUI

struct CreatePlanView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var category: PlanCategory = .personal
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var location = ""

    @State private var tripBudget = ""
    @State private var tripAirline = ""
    @State private var tripHotel = ""
    @State private var tripPackingItem = ""
    @State private var tripPackingList: [String] = []

    @State private var workPriority: WorkPriority = .medium
    @State private var workNotes = ""

    @State private var friendsAttendeeInput = ""
    @State private var friendsAttendees: [String] = []

    @State private var healthType: HealthType = .gym
    @State private var healthGoal = ""
    @State private var healthFrequency = ""

    @State private var otherNotes = ""

    @State private var selectedImageData: Data? = nil
    @State private var showImagePicker = false
    @State private var photoItem: PhotosPickerItem? = nil
    @State private var showTemplatePicker = false
    @AppStorage("customTemplates") private var customTemplatesData: Data = Data()
    
    @State private var momentCaptureEnabled = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Button {
                        showTemplatePicker = true
                    } label: {
                        HStack {
                            Image(systemName: "square.on.square")
                                .foregroundStyle(.blue)
                            Text("Use a Template")
                                .foregroundStyle(.blue)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("Details") {
                    TextField("Title", text: $title)
                    Picker("Category", selection: $category) {
                        ForEach(PlanCategory.allCases, id: \.self) { cat in
                            Label(cat.rawValue, systemImage: cat.icon).tag(cat)
                        }
                    }
                    TextField("Location (for weather)", text: $location)
                }

                Section("Cover Image") {
                    if let imageData = selectedImageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 180)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .onTapGesture { showImagePicker = true }
                    } else {
                        Button {
                            showImagePicker = true
                        } label: {
                            HStack {
                                Image(systemName: "photo.badge.plus")
                                Text("Add Cover Image")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
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
                    Toggle(isOn: $momentCaptureEnabled) {
                        HStack(spacing: 8) {
                            Image(systemName: "camera.fill")
                                .foregroundStyle(.blue)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Daily Moment Capture")
                                    .font(.subheadline)
                                Text("Get a random daily nudge to take a photo")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
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
                    
                    Toggle(isOn: $momentCaptureEnabled) {
                        HStack(spacing: 8) {
                            Image(systemName: "camera.fill")
                                .foregroundStyle(.blue)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Daily Moment Capture")
                                    .font(.subheadline)
                                Text("Get a random daily nudge to take a photo")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
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

                if !title.isEmpty {
                    Section {
                        Button {
                            saveAsTemplate()
                        } label: {
                            HStack {
                                Image(systemName: "square.and.arrow.down").foregroundStyle(.green)
                                Text("Save as Template").foregroundStyle(.green)
                            }
                        }
                    }
                }
            }
            .photosPicker(isPresented: $showImagePicker, selection: $photoItem, matching: .images)
            .onChange(of: photoItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        selectedImageData = data
                    }
                }
            }
            .sheet(isPresented: $showTemplatePicker) {
                TemplatePickerView { template in
                    title = template.title
                    category = template.category
                }
            }
            .navigationTitle("New Plan")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let plan = PlansModel(title: title, category: category, startDate: startDate, endDate: endDate)
                        plan.location = location.isEmpty ? nil : location
                        plan.tripAirline = tripAirline.isEmpty ? nil : tripAirline
                        plan.tripHotel = tripHotel.isEmpty ? nil : tripHotel
                        plan.tripBudget = Double(tripBudget)
                        plan.tripPackingList = tripPackingList
                        plan.workPriority = workPriority
                        plan.workNotes = workNotes.isEmpty ? nil : workNotes
                        plan.friendsLocation = location.isEmpty ? nil : location
                        plan.friendsAttendees = friendsAttendees
                        plan.healthType = healthType
                        plan.healthGoal = healthGoal.isEmpty ? nil : healthGoal
                        plan.healthFrequency = healthFrequency.isEmpty ? nil : healthFrequency
                        plan.otherNotes = otherNotes.isEmpty ? nil : otherNotes
                        plan.imageData = selectedImageData
                        modelContext.insert(plan)
                        NotificationManager.schedule(for: plan)
                        plan.momentCaptureEnabled = momentCaptureEnabled
                        modelContext.insert(plan)
                        NotificationManager.schedule(for: plan)
                        MomentNotificationManager.scheduleRandomMoments(for: plan)
                        dismiss()
                        if endDate < startDate {
                            endDate = startDate.addingTimeInterval(3600)
                        }
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }

    func saveAsTemplate() {
        let template = PlanTemplate(
            title: title,
            categoryRaw: category.rawValue,
            icon: category.icon,
            isCustom: true
        )
        var templates = (try? JSONDecoder().decode([PlanTemplate].self, from: customTemplatesData)) ?? []
        templates.append(template)
        customTemplatesData = (try? JSONEncoder().encode(templates)) ?? Data()
    }
}

#Preview {
    CreatePlanView()
        .modelContainer(for: PlansModel.self, inMemory: true)
}
