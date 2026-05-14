//
//  PlansModel.swift
//  MapOut
//
//  Created by Mate Javakhadze on 19.04.26.
//

import SwiftData
import Foundation
import SwiftUI

enum PlanCategory: String, Codable, CaseIterable, Equatable {
    case personal = "Personal"
    case work = "Work"
    case friends = "Friends"
    case trip = "Trip"
    case health = "Health"
    case other = "Other"

    var icon: String {
        switch self {
        case .personal: return "person.fill"
        case .work:     return "briefcase.fill"
        case .friends:  return "figure.2.arms.open"
        case .trip:     return "airplane"
        case .health:   return "heart.fill"
        case .other:    return "ellipsis.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .personal: return .blue
        case .work:     return .indigo
        case .friends:  return .green
        case .trip:     return .orange
        case .health:   return .red
        case .other:    return .purple
        }
    }
}

enum WorkPriority: String, Codable, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
}

enum HealthType: String, Codable, CaseIterable {
    case gym = "Gym"
    case diet = "Diet"
    case sleep = "Sleep"
}

@Model
class PlansModel {
    var id: String
    var title: String
    var categoryRaw: String
    var startDate: Date
    var endDate: Date
    var isCompleted: Bool
    var completedDate: Date?

    var tripBudget: Double?
    var tripAirline: String?
    var tripHotel: String?
    var tripPackingList: [String]

    var workPriorityRaw: String?
    var workNotes: String?

    var friendsLocation: String?
    var friendsAttendees: [String]

    var healthTypeRaw: String?
    var healthGoal: String?
    var healthFrequency: String?

    var otherNotes: String?
    
    var photoLog: [Data] = []
    
    var momentCaptureEnabled: Bool = false
    
    var location: String?
    
    var isArchived: Bool = false

    var category: PlanCategory {
        get { PlanCategory(rawValue: categoryRaw) ?? .personal }
        set { categoryRaw = newValue.rawValue }
    }

    var workPriority: WorkPriority {
        get { WorkPriority(rawValue: workPriorityRaw ?? "") ?? .medium }
        set { workPriorityRaw = newValue.rawValue }
    }

    var healthType: HealthType {
        get { HealthType(rawValue: healthTypeRaw ?? "") ?? .gym }
        set { healthTypeRaw = newValue.rawValue }
    }
    
    var imageData: Data?

    init(id: String = UUID().uuidString, title: String, category: PlanCategory, startDate: Date, endDate: Date) {
        self.id = id
        self.title = title
        self.categoryRaw = category.rawValue
        self.startDate = startDate
        self.endDate = endDate
        self.isCompleted = false
        self.completedDate = nil
        self.tripPackingList = []
        self.friendsAttendees = []
        
    }
}
