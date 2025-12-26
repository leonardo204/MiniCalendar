// WeekdayHeaderView.swift
// MiniCalendar
//
// 요일 헤더 뷰

import SwiftUI

struct WeekdayHeaderView: View {
    @EnvironmentObject var settingsManager: SettingsManager

    /// 요일 배열 (설정에 따라 순서 변경)
    private var weekdays: [String] {
        let allWeekdays = ["일", "월", "화", "수", "목", "금", "토"]
        if settingsManager.weekStartsOnMonday {
            // 월요일 시작: 월, 화, 수, 목, 금, 토, 일
            return Array(allWeekdays[1...]) + [allWeekdays[0]]
        } else {
            // 일요일 시작: 일, 월, 화, 수, 목, 금, 토
            return allWeekdays
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(weekdays.enumerated()), id: \.offset) { index, weekday in
                Text(weekday)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(weekdayColor(for: index))
                    .frame(maxWidth: .infinity)
            }
        }
    }

    /// 요일에 따른 색상 (주말 구분)
    private func weekdayColor(for index: Int) -> Color {
        if settingsManager.weekStartsOnMonday {
            // 월요일 시작: 5 = 토요일, 6 = 일요일
            if index == 6 {
                return .sundayRed  // 일요일: 붉은색
            } else if index == 5 {
                return .secondary  // 토요일: 회색
            }
        } else {
            // 일요일 시작: 0 = 일요일, 6 = 토요일
            if index == 0 {
                return .sundayRed  // 일요일: 붉은색
            } else if index == 6 {
                return .secondary  // 토요일: 회색
            }
        }
        return .primary
    }
}

#Preview {
    WeekdayHeaderView()
        .environmentObject(SettingsManager.shared)
        .padding()
}
