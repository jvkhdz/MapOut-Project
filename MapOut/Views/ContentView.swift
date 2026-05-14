//
//  ContentView.swift
//  MapOut
//
//  Created by Mate Javakhadze on 19.04.26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        PlansView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: PlansModel.self, inMemory: true)
}
