//
//  CategorySectionView.swift
//  MapOut
//
//  Created by Mate Javakhadze on 19.04.26.
//

import SwiftUI
import SwiftData

struct CategorySectionView: View {
    let category: PlanCategory
    let plans: [PlansModel]
    let onDelete: (PlansModel) -> Void
    let onToggleComplete: (PlansModel) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header
            HStack(spacing: 8) {
                Image(systemName: category.icon)
                Text(category.rawValue)
                    .font(.title2)
                    .bold()
                Text("\(plans.count)")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color(.systemGray5))
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(plans) { plan in
                    PlanBoxView(plan: plan, onDelete: onDelete, onToggleComplete: onToggleComplete)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
}
#Preview {
    CategorySectionView(
        category: .personal,
        plans: [],
        onDelete: { _ in },
        onToggleComplete: { _ in }
    )
    .modelContainer(for: PlansModel.self, inMemory: true)
}
