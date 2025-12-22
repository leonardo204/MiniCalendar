// Date+Extensions.swift
// MiniCalendar
//
// Date 타입 확장

import Foundation

extension Date {
    /// 현재 캘린더
    private var calendar: Calendar {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "ko_KR")
        return calendar
    }

    /// 해당 월의 시작일
    var startOfMonth: Date {
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }

    /// 해당 월의 마지막일
    var endOfMonth: Date {
        guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth) else {
            return self
        }
        return calendar.date(byAdding: .day, value: -1, to: nextMonth) ?? self
    }

    /// 해당 월의 일 수
    var numberOfDaysInMonth: Int {
        calendar.range(of: .day, in: .month, for: self)?.count ?? 30
    }

    /// 해당 월 시작일의 요일 (0 = 일요일, 1 = 월요일, ...)
    var firstWeekdayOfMonth: Int {
        calendar.component(.weekday, from: startOfMonth) - 1
    }

    /// 이전 월
    var previousMonth: Date {
        calendar.date(byAdding: .month, value: -1, to: self) ?? self
    }

    /// 다음 월
    var nextMonth: Date {
        calendar.date(byAdding: .month, value: 1, to: self) ?? self
    }

    /// 오늘인지 확인
    var isToday: Bool {
        calendar.isDateInToday(self)
    }

    /// 같은 월인지 확인
    func isSameMonth(as date: Date) -> Bool {
        let selfComponents = calendar.dateComponents([.year, .month], from: self)
        let dateComponents = calendar.dateComponents([.year, .month], from: date)
        return selfComponents.year == dateComponents.year && selfComponents.month == dateComponents.month
    }

    /// 년/월 문자열 (예: "2025년 12월")
    var monthYearString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월"
        return formatter.string(from: self)
    }

    /// 이전 년도
    var previousYear: Date {
        calendar.date(byAdding: .year, value: -1, to: self) ?? self
    }

    /// 다음 년도
    var nextYear: Date {
        calendar.date(byAdding: .year, value: 1, to: self) ?? self
    }

    /// 해당 월의 달력에 표시할 모든 날짜 배열 생성
    /// - Parameter weekStartsOnMonday: 월요일 시작 여부
    /// - Returns: CalendarDay 배열 (6주 x 7일 = 42개)
    func calendarDays(weekStartsOnMonday: Bool) -> [CalendarDay] {
        var days: [CalendarDay] = []
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "ko_KR")

        // 주 시작 요일 설정
        calendar.firstWeekday = weekStartsOnMonday ? 2 : 1 // 2 = 월요일, 1 = 일요일

        // 해당 월의 시작일
        let startOfMonth = self.startOfMonth

        // 시작일의 요일 (0-6)
        var firstWeekday = calendar.component(.weekday, from: startOfMonth)
        // 주 시작 요일에 맞게 조정
        if weekStartsOnMonday {
            firstWeekday = (firstWeekday + 5) % 7 // 월요일 = 0, 화요일 = 1, ..., 일요일 = 6
        } else {
            firstWeekday = firstWeekday - 1 // 일요일 = 0, 월요일 = 1, ...
        }

        // 이전 월의 날짜들
        let previousMonth = self.previousMonth
        let daysInPreviousMonth = previousMonth.numberOfDaysInMonth
        for i in (0..<firstWeekday).reversed() {
            if let date = calendar.date(
                byAdding: .day,
                value: daysInPreviousMonth - i - 1,
                to: previousMonth.startOfMonth
            ) {
                days.append(CalendarDay(date: date, isCurrentMonth: false, isToday: date.isToday))
            }
        }

        // 현재 월의 날짜들
        let daysInMonth = self.numberOfDaysInMonth
        for day in 0..<daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day, to: startOfMonth) {
                days.append(CalendarDay(date: date, isCurrentMonth: true, isToday: date.isToday))
            }
        }

        // 다음 월의 날짜들 (6주를 채우기 위해)
        let remainingDays = 42 - days.count
        let nextMonth = self.nextMonth
        for day in 0..<remainingDays {
            if let date = calendar.date(byAdding: .day, value: day, to: nextMonth.startOfMonth) {
                days.append(CalendarDay(date: date, isCurrentMonth: false, isToday: date.isToday))
            }
        }

        return days
    }
}
