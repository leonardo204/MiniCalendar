// CalendarGridView.swift
// MiniCalendar
//
// 달력 그리드 뷰

import SwiftUI

struct CalendarGridView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    let displayedMonth: Date

    /// 그리드 열 정의 (7일)
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    /// 표시할 날짜 배열
    private var days: [CalendarDay] {
        displayedMonth.calendarDays(weekStartsOnMonday: settingsManager.weekStartsOnMonday)
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
        .padding()
}
