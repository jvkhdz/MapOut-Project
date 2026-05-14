import SwiftUI
import SwiftData

struct MemoryWallView: View {
    @Query private var allPlans: [PlansModel]
    @State private var selectedPlan: PlansModel? = nil

    var completedPlans: [PlansModel] {
        allPlans
            .filter { $0.isCompleted || $0.isArchived }
            .sorted { ($0.completedDate ?? Date()) > ($1.completedDate ?? Date()) }
    }
    
    

    var body: some View {
        NavigationStack {
            ScrollView {
                if completedPlans.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 60))
                            .foregroundStyle(.secondary)
                        Text("No memories yet")
                            .font(.title2)
                            .bold()
                        Text("Complete plans to see them here")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 100)
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(completedPlans) { plan in
                            Button {
                                selectedPlan = plan
                            } label: {
                                MemoryCard(plan: plan)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Memories")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedPlan) { plan in
                MemoryDetailView(plan: plan)
            }
        }
    }
    
    struct MemoryDetailView: View {
        let plan: PlansModel
        @Environment(\.dismiss) private var dismiss

        var body: some View {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 0) {
                        if let imageData = plan.imageData, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                        }

                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: plan.category.icon)
                                    .foregroundStyle(plan.category.color)
                                Text(plan.category.rawValue)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Label("Completed", systemImage: "checkmark.circle.fill")
                                    .font(.caption)
                                    .foregroundStyle(.green)
                            }

                            Text(plan.title)
                                .font(.title2)
                                .bold()

                            if let completedDate = plan.completedDate {
                                Label(completedDate.formatted(date: .long, time: .omitted), systemImage: "calendar.badge.checkmark")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            if let location = plan.location, !location.isEmpty {
                                Label(location, systemImage: "mappin.circle")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            // Photo log
                            if !plan.photoLog.isEmpty {
                                PhotoLogView(plan: plan)
                            }
                        }
                        .padding()
                    }
                }
                .navigationTitle(plan.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { dismiss() }
                    }
                }
            }
        }
    }
}

struct MemoryCard: View {
    let plan: PlansModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let imageData = plan.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 180)
                    .clipped()
            } else {
                plan.category.color
                    .frame(maxWidth: .infinity)
                    .frame(height: 80)
                    .overlay {
                        Image(systemName: plan.category.icon)
                            .font(.largeTitle)
                            .foregroundStyle(.white.opacity(0.5))
                    }
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label(plan.category.rawValue, systemImage: plan.category.icon)
                        .font(.caption)
                        .foregroundStyle(plan.category.color)
                    Spacer()
                    if let completedDate = plan.completedDate {
                        Text(completedDate.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Text(plan.title)
                    .font(.headline)
                    .bold()

                if let location = plan.location, !location.isEmpty {
                    Label(location, systemImage: "mappin.circle")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if !plan.photoLog.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(Array(plan.photoLog.prefix(4).enumerated()), id: \.offset) { index, data in
                            if let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 44, height: 44)
                                    .clipped()
                                    .cornerRadius(6)
                            }
                        }
                        if plan.photoLog.count > 4 {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(.systemGray5))
                                .frame(width: 44, height: 44)
                                .overlay {
                                    Text("+\(plan.photoLog.count - 4)")
                                        .font(.caption)
                                        .bold()
                                        .foregroundStyle(.secondary)
                                }
                        }
                    }
                }
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [plan.category.color.opacity(0.15), plan.category.color.opacity(0.05)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .cornerRadius(16)
        .shadow(color: plan.category.color.opacity(0.25), radius: 10, x: 0, y: 4)
    }
}

#Preview {
    MemoryWallView()
        .modelContainer(for: PlansModel.self, inMemory: true)
}
