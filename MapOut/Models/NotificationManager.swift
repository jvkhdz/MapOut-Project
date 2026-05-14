//
//  NotificationManager.swift
//  MapOut
//
//  Created by Mate Javakhadze on 21.04.26.
//

import Foundation
import UserNotifications

struct NotificationManager {
    static func schedule(for plan: PlansModel) {
        let content = UNMutableNotificationContent()
        content.title = "Upcoming Plan 📍"
        content.body = "\(plan.title) starts soon!"
        content.sound = .default

        let triggerDate = Calendar.current.date(byAdding: .minute, value: -30, to: plan.startDate) ?? plan.startDate
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: plan.id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    static func cancel(for plan: PlansModel) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [plan.id])
    }
}
