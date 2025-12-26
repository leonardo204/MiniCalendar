// DayCell.swift
// MiniCalendar
//
// 개별 날짜 셀 뷰

import SwiftUI

struct DayCell: View {
    let day: CalendarDay
    @State private var isHovering = false

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
        .onHover { hovering in
            isHovering = hovering
        }
        .popover(isPresented: Binding(
            get: { isHovering && day.holiday != nil },
            set: { isHovering = $0 }
        ), arrowEdge: .top) {
            if let holiday = day.holiday {
                HolidayTooltipContent(name: holiday.name)
            }
        }
    }

    /// 텍스트 색상
    private var textColor: Color {
        // 오늘 날짜: 흰색 (빨간 원 배경 위)
        if day.isToday {
            return .white
        }

        // 일요일 또는 공휴일: 붉은색
        if day.isHolidayOrSunday {
            if day.isCurrentMonth {
                return .sundayRed
            } else {
                return .sundayRed.opacity(0.5)
            }
        }

        // 일반 날짜
        if day.isCurrentMonth {
            return .primary
        } else {
            return .secondary.opacity(0.5)
        }
    }
}

// MARK: - 툴팁 내용

struct HolidayTooltipContent: View {
    let name: String

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(Color.sundayRed)
                .frame(width: 6, height: 6)

            Text(name)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
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
