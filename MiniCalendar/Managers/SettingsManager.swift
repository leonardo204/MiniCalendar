// SettingsManager.swift
// MiniCalendar
//
// 앱 설정 관리 및 UserDefaults 저장/로드

import Foundation
import SwiftUI
import ServiceManagement

class SettingsManager: ObservableObject {
    // 싱글톤 인스턴스
    static let shared = SettingsManager()

    // MARK: - 일반 설정

    /// 로그인 시 자동 실행
    @Published var openAtLogin: Bool = false {
        didSet { setLaunchAtLogin(openAtLogin) }
    }

    /// 아이콘만 표시
    @Published var showOnlyIcon: Bool = false

    // MARK: - 시간 옵션

    /// 시간 표시
    @Published var showTime: Bool = true

    /// 초 단위 표시
    @Published var showSeconds: Bool = false

    /// 24시간제 사용
    @Published var use24HourClock: Bool = true

    /// AM/PM 표시 (12시간제일 때만 유효)
    @Published var showAMPM: Bool = true

    // MARK: - 날짜 옵션

    /// 날짜 표시
    @Published var showDate: Bool = true

    /// 날짜 형식 (E: 요일, M: 월, d: 일, yyyy: 년도 등 포함 가능)
    @Published var dateFormat: String = "M월 d일 (E)"

    // MARK: - 달력 옵션

    /// 월요일 시작 (false면 일요일 시작)
    @Published var weekStartsOnMonday: Bool = false

    // MARK: - UserDefaults 키
    private let userDefaultsKey = "MiniCalendarSettings"

    // MARK: - 초기화

    private init() {
        load()
    }

    // MARK: - 저장/로드

    /// UserDefaults에서 설정 로드
    func load() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else {
            return
        }

        do {
            let settings = try JSONDecoder().decode(AppSettings.self, from: data)
            applySettings(settings)
        } catch {
            print("설정 로드 실패: \(error)")
        }
    }

    /// UserDefaults에 설정 저장
    func save() {
        let settings = AppSettings(
            openAtLogin: openAtLogin,
            showOnlyIcon: showOnlyIcon,
            showTime: showTime,
            showSeconds: showSeconds,
            use24HourClock: use24HourClock,
            showAMPM: showAMPM,
            showDate: showDate,
            dateFormat: dateFormat,
            weekStartsOnMonday: weekStartsOnMonday
        )

        do {
            let data = try JSONEncoder().encode(settings)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        } catch {
            print("설정 저장 실패: \(error)")
        }
    }

    /// AppSettings 구조체에서 속성 적용
    private func applySettings(_ settings: AppSettings) {
        // openAtLogin은 didSet에서 SMAppService를 호출하므로 마지막에 설정
        showOnlyIcon = settings.showOnlyIcon
        showTime = settings.showTime
        showSeconds = settings.showSeconds
        use24HourClock = settings.use24HourClock
        showAMPM = settings.showAMPM
        showDate = settings.showDate
        dateFormat = settings.dateFormat
        weekStartsOnMonday = settings.weekStartsOnMonday

        // SMAppService 상태 확인 후 설정 (didSet 트리거 방지를 위해 직접 할당)
        _openAtLogin = Published(initialValue: settings.openAtLogin)
    }

    // MARK: - 로그인 시 자동 실행

    /// 로그인 시 자동 실행 설정
    private func setLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("로그인 시 자동 실행 설정 실패: \(error)")
        }
    }
}
