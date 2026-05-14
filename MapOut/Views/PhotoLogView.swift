//
//  PhotoLogView.swift
//  MapOut
//
//  Created by Mate Javakhadze on 29.04.26.
//

import SwiftUI
import PhotosUI
import SwiftData


struct PhotoLogView: View {
    let plan: PlansModel
    @State private var photoItem: PhotosPickerItem? = nil
    @State private var showPhotoPicker = false

    let columns = [GridItem(.flexible(), spacing: 4), GridItem(.flexible(), spacing: 4), GridItem(.flexible(), spacing: 4)]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Photo Log")
                    .font(.title3)
                    .bold()
                Spacer()
                Button {
                    showPhotoPicker = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.blue)
                }
            }

            if plan.photoLog.isEmpty {
                Button {
                    showPhotoPicker = true
                } label: {
                    HStack {
                        Image(systemName: "photo.badge.plus")
                        Text("Add photos to log")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .foregroundStyle(.secondary)
                }
            } else {
                LazyVGrid(columns: columns, spacing: 4) {
                    ForEach(Array(plan.photoLog.enumerated()), id: \.offset) { index, data in
                        if let uiImage = UIImage(data: data) {
                            GeometryReader { geo in
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: geo.size.width, height: geo.size.width)
                                    .clipped()
                                    .cornerRadius(6)
                            }
                            .aspectRatio(1, contentMode: .fit)
                            .contextMenu {
                                Button(role: .destructive) {
                                    plan.photoLog.remove(at: index)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }

                    Button {
                        showPhotoPicker = true
                    } label: {
                        GeometryReader { geo in
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(.systemGray6))
                                .frame(width: geo.size.width, height: geo.size.width)
                                .overlay {
                                    Image(systemName: "plus")
                                        .font(.title2)
                                        .foregroundStyle(.secondary)
                                }
                        }
                        .aspectRatio(1, contentMode: .fit)
                    }
                }
            }
        }
        .photosPicker(isPresented: $showPhotoPicker, selection: $photoItem, matching: .images)
        .onChange(of: photoItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    plan.photoLog.append(data)
                    photoItem = nil
                }
            }
        }
    }
}

#Preview {
    PhotoLogView(plan: PlansModel(title: "Paris Trip", category: .trip, startDate: Date(), endDate: Date()))
        .modelContainer(for: PlansModel.self, inMemory: true)
        .padding()
}
