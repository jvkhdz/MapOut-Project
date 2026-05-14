//
//  MapOutApp.swift
//  MapOut
//
//  Created by Mate Javakhadze on 19.04.26.
//

import SwiftUI
import SwiftData
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo
        if let planID = userInfo["planID"] as? String,
           userInfo["momentCapture"] as? Bool == true {
            NotificationCenter.default.post(
                name: .openMomentCapture,
                object: nil,
                userInfo: ["planID": planID]
            )
        }
    }
}

extension Notification.Name {
    static let openMomentCapture = Notification.Name("openMomentCapture")
}

@main
struct MapOutApp: App {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let container: ModelContainer

    init() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }

        do {
            let url = FileManager.default
                .containerURL(forSecurityApplicationGroupIdentifier: "group.com.matejavakhadze.mapout")!
                .appendingPathComponent("plans.store")
            let config = ModelConfiguration(url: url)
            container = try ModelContainer(for: PlansModel.self, configurations: config)
        } catch {
            fatalError("Failed to create container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    TabView {
                        PlansView()
                            .tabItem { Label("Plans", systemImage: "list.bullet") }
                        CalendarView()
                            .tabItem { Label("Calendar", systemImage: "calendar") }
                        StatsView()
                            .tabItem { Label("Stats", systemImage: "chart.bar.fill") }
                        MemoryWallView()
                            .tabItem { Label("Memories", systemImage: "photo.on.rectangle") }
                    }
                } else {
                    OnboardingView()
                }
            }
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .animation(.easeInOut, value: hasCompletedOnboarding)
        }
        .modelContainer(container)
    }
}
