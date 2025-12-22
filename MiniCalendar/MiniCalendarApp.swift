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
        // 메뉴 막대 전용 앱이므로 WindowGroup 대신 Settings만 사용
        Settings {
            EmptyView()
        }
    }
}
