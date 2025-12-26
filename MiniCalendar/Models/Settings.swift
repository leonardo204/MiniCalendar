// Settings.swift
// MiniCalendar
//
// 설정 데이터 모델

import Foundation

/// 앱 설정을 저장하기 위한 Codable 구조체
struct AppSettings: Codable {
    // MARK: - 일반 설정

    /// 로그인 시 자동 실행
    var openAtLogin: Bool

    /// 아이콘만 표시
    var showOnlyIcon: Bool

    // MARK: - 시간 옵션

    /// 시간 표시
    var showTime: Bool

    /// 초 단위 표시
    var showSeconds: Bool

    /// 24시간제 사용
    var use24HourClock: Bool

    /// AM/PM 표시
    var showAMPM: Bool

    // MARK: - 날짜 옵션

    /// 날짜 표시
    var showDate: Bool

    /// 날짜 형식 (E: 요일, M: 월, d: 일, yyyy: 년도 등 포함 가능)
    var dateFormat: String

    // MARK: - 달력 옵션

    /// 월요일 시작 (false면 일요일 시작)
    var weekStartsOnMonday: Bool

    // MARK: - 공휴일 옵션

    /// 공휴일 표시 여부
    var showHolidays: Bool

    /// 공휴일 국가 코드 (KR, US, JP 등)
    var holidayCountryCode: String

    // MARK: - 기본값

    /// 기본 설정값
    static var `default`: AppSettings {
        // 시스템 로케일에서 국가 코드 추출
        let systemCountryCode = Locale.current.region?.identifier ?? "KR"
        // 지원하는 국가인지 확인, 아니면 KR 사용
        let supportedCodes = ["KR", "US", "JP", "CN", "GB"]
        let defaultCountryCode = supportedCodes.contains(systemCountryCode) ? systemCountryCode : "KR"

        return AppSettings(
            openAtLogin: false,
            showOnlyIcon: false,
            showTime: true,
            showSeconds: false,
            use24HourClock: true,
            showAMPM: true,
            showDate: true,
            dateFormat: "M월 d일 (E)",
            weekStartsOnMonday: false,
            showHolidays: true,
            holidayCountryCode: defaultCountryCode
        )
    }
}
