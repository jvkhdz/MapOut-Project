//
//  MomentNotificationManager.swift
//  MapOut
//
//  Created by Mate Javakhadze on 14.05.26.
//

import UserNotifications
import Foundation

struct MomentNotificationManager {

    static func scheduleRandomMoments(for plan: PlansModel) {
        guard plan.momentCaptureEnabled else { return }
        guard plan.category == .trip || plan.category == .friends else { return }

        let center = UNUserNotificationCenter.current()

        // Cancel existing moment notifications for this plan
        cancelMoments(for: plan)

        let calendar = Calendar.current
        var date = max(plan.startDate, Date())
        let endDate = plan.endDate

        while date <= endDate {
            let randomHour = Int.random(in: 9...21)
            let randomMinute = Int.random(in: 0...59)

            guard let fireDate = calendar.date(bySettingHour: randomHour, minute: randomMinute, second: 0, of: date),
                  fireDate > Date() else {
                date = calendar.date(byAdding: .day, value: 1, to: date) ?? date
                continue
            }

            let content = UNMutableNotificationContent()
            content.title = "📸 Capture the moment!"
            content.body = "You're in the middle of \(plan.title) — take a photo!"
            content.sound = .default
            content.userInfo = ["planID": plan.id, "momentCapture": true]

            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let identifier = "moment-\(plan.id)-\(fireDate.timeIntervalSince1970)"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

            center.add(request)
            date = calendar.date(byAdding: .day, value: 1, to: date) ?? date
        }
    }

    static func cancelMoments(for plan: PlansModel) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let ids = requests
                .filter { $0.identifier.hasPrefix("moment-\(plan.id)") }
                .map { $0.identifier }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
        }
    }
}
