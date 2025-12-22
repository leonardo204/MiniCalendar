// DayCell.swift
// MiniCalendar
//
// 개별 날짜 셀 뷰

import SwiftUI

struct DayCell: View {
    let day: CalendarDay

    var body: some View {
        ZStack {
            // 오늘 날짜 배경
            if day.isToday {
                Circle()
                    .fill(Color.red)
                    .frame(width: 28, height: 28)
            }

            // 날짜 텍스트
            Text("\(day.dayNumber)")
                .font(.system(size: 13))
                .fontWeight(day.isToday ? .bold : .regular)
                .foregroundColor(textColor)
        }
        .frame(height: 32)
        .frame(maxWidth: .infinity)
    }

    /// 텍스트 색상
    private var textColor: Color {
        if day.isToday {
            return .white
        } else if day.isCurrentMonth {
            return .primary
        } else {
            return .secondary.opacity(0.5)
        }
    }
}

#Preview {
    HStack {
        DayCell(day: CalendarDay(date: Date(), isCurrentMonth: true, isToday: true))
        DayCell(day: CalendarDay(date: Date(), isCurrentMonth: true, isToday: false))
        DayCell(day: CalendarDay(date: Date(), isCurrentMonth: false, isToday: false))
    }
    .padding()
}
