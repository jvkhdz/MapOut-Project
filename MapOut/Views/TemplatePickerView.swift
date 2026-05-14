//
//  TemplatePickerView.swift
//  MapOut
//
//  Created by Mate Javakhadze on 29.04.26.
//

import SwiftUI

struct TemplatePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("customTemplates") private var customTemplatesData: Data = Data()
    let onSelect: (PlanTemplate) -> Void

    var customTemplates: [PlanTemplate] {
        (try? JSONDecoder().decode([PlanTemplate].self, from: customTemplatesData)) ?? []
    }

    var body: some View {
        NavigationStack {
            List {
                if !customTemplates.isEmpty {
                    Section("My Templates") {
                        ForEach(customTemplates) { template in
                            TemplateRow(template: template) {
                                onSelect(template)
                                dismiss()
                            }
                        }
                        .onDelete { indices in
                            var templates = customTemplates
                            templates.remove(atOffsets: indices)
                            customTemplatesData = (try? JSONEncoder().encode(templates)) ?? Data()
                        }
                    }
                }

                Section("Quick Start") {
                    ForEach(PlanTemplate.prebuilt) { template in
                        TemplateRow(template: template) {
                            onSelect(template)
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle("Templates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

struct TemplateRow: View {
    let template: PlanTemplate
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: template.icon)
                    .font(.title3)
                    .foregroundStyle(template.category.color)
                    .frame(width: 36, height: 36)
                    .background(template.category.color.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 2) {
                    Text(template.title)
                        .font(.subheadline)
                        .bold()
                        .foregroundStyle(.primary)
                    Text(template.category.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    TemplatePickerView(onSelect: { _ in })
}
