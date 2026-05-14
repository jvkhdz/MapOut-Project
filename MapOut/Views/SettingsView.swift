//
//  SettingsView.swift
//  MapOut
//
//  Created by Mate Javakhadze on 19.04.26.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("isDarkMode") private var isDarkMode = false
    let planCount: Int

    var body: some View {
        NavigationStack {
            Form {
                Section("Appearance") {
                    Toggle(isOn: $isDarkMode) {
                        Label("Dark Mode", systemImage: "moon.fill")
                    }
                }
                Section("Stats") {
                    HStack {
                        Label("Total Plans Created", systemImage: "chart.bar.fill")
                        Spacer()
                        Text("\(planCount)")
                            .foregroundStyle(.secondary)
                    }
                }
                Section("Info") {
                    Label("Completed plans with photos are archived to Memories. Plans without photos are deleted after 3 days.", systemImage: "archivebox.circle")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    SettingsView(planCount: 5)
}
