// MiniCalendarTests.swift
// MiniCalendarTests
//
// MiniCalendar 단위 테스트

import XCTest
@testable import MiniCalendar

final class MiniCalendarTests: XCTestCase {

    override func setUpWithError() throws {
        // 테스트 전 설정
    }

    override func tearDownWithError() throws {
        // 테스트 후 정리
    }

    // MARK: - Settings 테스트

    func testSettingsDefaultValues() throws {
        let settings = AppSettings.default

        XCTAssertFalse(settings.openAtLogin)
        XCTAssertFalse(settings.showOnlyIcon)
        XCTAssertTrue(settings.showTime)
        XCTAssertFalse(settings.showSeconds)
        XCTAssertTrue(settings.use24HourClock)
        XCTAssertTrue(settings.showAMPM)
        XCTAssertTrue(settings.showDate)
        XCTAssertEqual(settings.dateFormat, "M월 d일 (E)")
        XCTAssertFalse(settings.weekStartsOnMonday)
    }

    // MARK: - Date Extensions 테스트

    func testStartOfMonth() throws {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let date = formatter.date(from: "2025-12-15")!
        let startOfMonth = date.startOfMonth

        let calendar = Calendar.current
        XCTAssertEqual(calendar.component(.day, from: startOfMonth), 1)
        XCTAssertEqual(calendar.component(.month, from: startOfMonth), 12)
        XCTAssertEqual(calendar.component(.year, from: startOfMonth), 2025)
    }

    func testNumberOfDaysInMonth() throws {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        // 12월 = 31일
        let december = formatter.date(from: "2025-12-15")!
        XCTAssertEqual(december.numberOfDaysInMonth, 31)

        // 2월 (평년) = 28일
        let february2025 = formatter.date(from: "2025-02-15")!
        XCTAssertEqual(february2025.numberOfDaysInMonth, 28)

        // 2월 (윤년) = 29일
        let february2024 = formatter.date(from: "2024-02-15")!
        XCTAssertEqual(february2024.numberOfDaysInMonth, 29)
    }

    func testPreviousAndNextMonth() throws {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let date = formatter.date(from: "2025-12-15")!
        let calendar = Calendar.current

        let previousMonth = date.previousMonth
        XCTAssertEqual(calendar.component(.month, from: previousMonth), 11)

        let nextMonth = date.nextMonth
        XCTAssertEqual(calendar.component(.month, from: nextMonth), 1)
        XCTAssertEqual(calendar.component(.year, from: nextMonth), 2026)
    }

    func testCalendarDaysCount() throws {
        let date = Date()

        // 일요일 시작
        let daysSunday = date.calendarDays(weekStartsOnMonday: false)
        XCTAssertEqual(daysSunday.count, 42) // 6주 x 7일

        // 월요일 시작
        let daysMonday = date.calendarDays(weekStartsOnMonday: true)
        XCTAssertEqual(daysMonday.count, 42)
    }

    // MARK: - CalendarDay 테스트

    func testCalendarDayProperties() throws {
        let today = Date()
        let day = CalendarDay(date: today, isCurrentMonth: true, isToday: true)

        XCTAssertTrue(day.isCurrentMonth)
        XCTAssertTrue(day.isToday)
        XCTAssertGreaterThan(day.dayNumber, 0)
        XCTAssertLessThanOrEqual(day.dayNumber, 31)
    }
}
