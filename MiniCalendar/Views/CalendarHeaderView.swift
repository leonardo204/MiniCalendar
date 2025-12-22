// CalendarHeaderView.swift
// MiniCalendar
//
// 달력 헤더 (년/월 표시, 네비게이션)

import SwiftUI

struct CalendarHeaderView: View {
    @Binding var displayedMonth: Date

    var body: some View {
        HStack {
            // 년/월 표시
            Text(displayedMonth.monthYearString)
                .font(.headline)
                .fontWeight(.semibold)

            Spacer()

            // 네비게이션 버튼
            HStack(spacing: 8) {
                // 설정 버튼 - 독립 윈도우 열기
                Button(action: {
                    SettingsWindowManager.shared.openSettings()
                }) {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("Settings")

                Spacer().frame(width: 4)

                // 이전 년도
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        displayedMonth = displayedMonth.previousYear
                    }
                }) {
                    Text("<<")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("Previous Year")

                // 이전 월
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        displayedMonth = displayedMonth.previousMonth
                    }
                }) {
                    Text("<")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("Previous Month")

                // 오늘로 이동
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        displayedMonth = Date()
                    }
                }) {
                    Circle()
                        .fill(Color.accentColor.opacity(0.8))
                        .frame(width: 8, height: 8)
                }
                .buttonStyle(.plain)
                .help("Go to Today")

                // 다음 월
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        displayedMonth = displayedMonth.nextMonth
                    }
                }) {
                    Text(">")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("Next Month")

                // 다음 년도
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        displayedMonth = displayedMonth.nextYear
                    }
                }) {
                    Text(">>")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("Next Year")
            }
        }
    }
}

#Preview {
    CalendarHeaderView(displayedMonth: .constant(Date()))
        .padding()
}
