// CalendarDay.swift
// MiniCalendar
//
// 달력 날짜 모델

import Foundation

/// 달력에 표시되는 개별 날짜를 나타내는 모델
struct CalendarDay: Identifiable {
    let id = UUID()

    /// 해당 날짜
    let date: Date

    /// 현재 표시 중인 월에 속하는지 여부
    let isCurrentMonth: Bool

    /// 오늘 날짜인지 여부
    let isToday: Bool

    /// 날짜 숫자 (1-31)
    var dayNumber: Int {
        Calendar.current.component(.day, from: date)
    }
}
