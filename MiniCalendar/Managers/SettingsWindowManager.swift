// SettingsWindowManager.swift
// MiniCalendar
//
// 독립적인 설정 윈도우 관리

import AppKit
import SwiftUI

class SettingsWindowManager {
    static let shared = SettingsWindowManager()

    private var settingsWindow: NSWindow?

    private init() {}

    /// 설정 윈도우 열기
    func openSettings() {
        // 이미 열려있으면 앞으로 가져오기
        if let window = settingsWindow, window.isVisible {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        // 새 윈도우 생성
        let settingsView = SettingsWindowView()
            .environmentObject(SettingsManager.shared)

        let hostingController = NSHostingController(rootView: settingsView)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 380, height: 480),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )

        window.title = "Settings"
        window.contentViewController = hostingController
        window.center()
        window.isReleasedWhenClosed = false
        window.level = .floating

        // 윈도우 닫힐 때 참조 정리
        window.delegate = WindowDelegate.shared

        settingsWindow = window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    /// 설정 윈도우 닫기
    func closeSettings() {
        settingsWindow?.close()
    }
}

// MARK: - Window Delegate

class WindowDelegate: NSObject, NSWindowDelegate {
    static let shared = WindowDelegate()

    func windowWillClose(_ notification: Notification) {
        // 윈도우 닫힐 때 설정 저장
        SettingsManager.shared.save()
    }
}
