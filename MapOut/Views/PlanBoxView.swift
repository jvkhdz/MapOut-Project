//
//  PlanBoxView.swift
//  MapOut
//
//  Created by Mate Javakhadze on 19.04.26.
//

import SwiftUI
import ConfettiSwiftUI

struct PlanBoxView: View {
    let plan: PlansModel
    let onDelete: (PlansModel) -> Void
    let onToggleComplete: (PlansModel) -> Void
    @State private var confettiCounter = 0

    var progress: Double {
        let total = plan.endDate.timeIntervalSince(plan.startDate)
        let elapsed = Date().timeIntervalSince(plan.startDate)
        guard total > 0 else { return 0 }
        return min(max(elapsed / total, 0), 1)
    }

    var progressLabel: String {
        if plan.isCompleted { return "Done" }
        if progress >= 1 { return "Overdue" }
        if progress <= 0 { return "Upcoming" }
        return "\(Int(progress * 100))%"
    }

    var body: some View {
        NavigationLink(destination: PlanDetailView(plan: plan, onDelete: onDelete)) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: plan.category.icon)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                    Spacer()
                    Button {
                        if !plan.isCompleted { confettiCounter += 1 }
                        onToggleComplete(plan)
                    } label: {
                        Image(systemName: plan.isCompleted ? "checkmark.circle.fill" : "circle")
                            .font(.title3)
                            .foregroundStyle(plan.isCompleted ? .green : .white.opacity(0.7))
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                Text(plan.title)
                    .font(.headline)
                    .bold()
                    .lineLimit(2)
                    .foregroundStyle(.white)

                Text(plan.startDate, style: .date)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))

                VStack(alignment: .leading, spacing: 3) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(.white.opacity(0.25))
                                .frame(height: 5)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(.white)
                                .frame(width: geo.size.width * progress, height: 5)
                                .animation(.easeInOut, value: progress)
                        }
                    }
                    .frame(height: 5)
                    
                    
                    if let imageData = plan.imageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .opacity(0.9)
                    }

                    Text(progressLabel)
                        .font(.system(size: 9))
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 150)
            .background(plan.category.color)
            .cornerRadius(12)
            .shadow(color: plan.category.color.opacity(0.4), radius: 8, x: 0, y: 0)
            .opacity(plan.isCompleted ? 0.6 : 1)
            .confettiCannon(trigger: $confettiCounter, num: 40, confettiSize: 8, rainHeight: 400, openingAngle: Angle(degrees: 60), closingAngle: Angle(degrees: 120), radius: 200)
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(role: .destructive) {
                onDelete(plan)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

#Preview {
    NavigationStack {
        PlanBoxView(
            plan: PlansModel(title: "Walk Dog", category: .personal, startDate: Date(), endDate: Date()),
            onDelete: { _ in },
            onToggleComplete: { _ in }
        )
        .padding()
    }
}
