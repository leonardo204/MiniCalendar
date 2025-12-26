// CalendarGridView.swift
// MiniCalendar
//
// 달력 그리드 뷰

import SwiftUI

struct CalendarGridView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var holidayService: HolidayService
    let displayedMonth: Date

    /// 그리드 열 정의 (7일)
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    /// 표시할 날짜 배열 (공휴일 정보 포함)
    private var days: [CalendarDay] {
        let baseDays = displayedMonth.calendarDays(weekStartsOnMonday: settingsManager.weekStartsOnMonday)

        // 공휴일 표시가 꺼져있으면 그대로 반환
        guard settingsManager.showHolidays else {
            return baseDays
        }

        // 공휴일 정보 주입
        return baseDays.map { day in
            var modifiedDay = day
            modifiedDay.holiday = holidayService.holiday(for: day.date)
            return modifiedDay
        }
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(days) { day in
                DayCell(day: day)
            }
        }
    }
}

#Preview {
    CalendarGridView(displayedMonth: Date())
        .environmentObject(SettingsManager.shared)
        .environmentObject(HolidayService.shared)
        .padding()
}
