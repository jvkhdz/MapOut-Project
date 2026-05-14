//
//  PlanTemplate.swift
//  MapOut
//
//  Created by Mate Javakhadze on 29.04.26.
//

import SwiftData
import Foundation
import SwiftUI

struct PlanTemplate: Identifiable, Codable {
    var id: String = UUID().uuidString
    var title: String
    var categoryRaw: String
    var icon: String
    var isCustom: Bool

    var category: PlanCategory {
        PlanCategory(rawValue: categoryRaw) ?? .personal
    }

    static let prebuilt: [PlanTemplate] = [
        PlanTemplate(title: "Weekend Trip", categoryRaw: "Trip", icon: "airplane", isCustom: false),
        PlanTemplate(title: "Gym Session", categoryRaw: "Health", icon: "figure.run", isCustom: false),
        PlanTemplate(title: "Team Meeting", categoryRaw: "Work", icon: "person.3.fill", isCustom: false),
        PlanTemplate(title: "Movie Night", categoryRaw: "Friends", icon: "film.fill", isCustom: false),
        PlanTemplate(title: "Study Session", categoryRaw: "Personal", icon: "book.fill", isCustom: false),
        PlanTemplate(title: "Doctor Appointment", categoryRaw: "Health", icon: "cross.fill", isCustom: false)
    ]
}
