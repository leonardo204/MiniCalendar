// MiniCalendarApp.swift
// MiniCalendar
//
// macOS 메뉴 막대 캘린더 애플리케이션

import SwiftUI

@main
struct MiniCalendarApp: App {
    // AppDelegate를 SwiftUI 앱에 연결
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // 설정 창 (Cmd+, 단축키로 열림)
        Settings {
            SettingsWindowView()
                .environmentObject(SettingsManager.shared)
                .environmentObject(HolidayService.shared)
        }
    }
}
