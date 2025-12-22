// AppDelegate.swift
// MiniCalendar
//
// 앱 생명주기 관리 및 메뉴 막대 앱 설정

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    // 상태 바 매니저 (메뉴 막대 아이템 관리)
    private var statusBarManager: StatusBarManager?

    // 최초 실행 확인 키
    private let hasLaunchedBeforeKey = "MiniCalendarHasLaunchedBefore"

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Dock 아이콘 숨기기 (메뉴 막대 전용 앱)
        NSApp.setActivationPolicy(.accessory)

        // 설정 로드
        SettingsManager.shared.load()

        // 상태 바 매니저 초기화
        statusBarManager = StatusBarManager()

        // 최초 실행 시 시스템 시계 끄기 안내
        checkFirstLaunch()
    }

    func applicationWillTerminate(_ notification: Notification) {
        // 앱 종료 시 설정 저장
        SettingsManager.shared.save()
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    // MARK: - 최초 실행 확인

    private func checkFirstLaunch() {
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: hasLaunchedBeforeKey)

        if !hasLaunchedBefore {
            UserDefaults.standard.set(true, forKey: hasLaunchedBeforeKey)
            showSystemClockGuide()
        }
    }

    private func showSystemClockGuide() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let alert = NSAlert()
            alert.messageText = "시스템 시계 숨기기"
            alert.informativeText = "MiniCalendar가 메뉴 막대에서 날짜와 시간을 표시합니다.\n\n기존 시스템 시계를 숨기려면 '설정 열기'를 클릭한 후:\n\n1. '시계' 항목을 찾으세요\n2. '메뉴 막대에서 보기'를 끄세요"
            alert.alertStyle = .informational
            alert.addButton(withTitle: "설정 열기")
            alert.addButton(withTitle: "나중에")

            let response = alert.runModal()

            if response == .alertFirstButtonReturn {
                self.openControlCenterSettings()
            }
        }
    }

    private func openControlCenterSettings() {
        // macOS 13+ 제어 센터 설정 열기
        if let url = URL(string: "x-apple.systempreferences:com.apple.ControlCenter-Settings.extension") {
            NSWorkspace.shared.open(url)
        }
    }
}
