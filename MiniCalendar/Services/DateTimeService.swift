// DateTimeService.swift
// MiniCalendar
//
// 날짜/시간 포맷팅 서비스

import Foundation

class DateTimeService: ObservableObject {
    // MARK: - 날짜/시간 포맷팅

    /// 설정에 따른 날짜/시간 문자열 생성
    func getFormattedDateTime() -> String {
        let settings = SettingsManager.shared
        var components: [String] = []

        // 날짜 부분 (요일 포함)
        if settings.showDate {
            components.append(getFormattedDate())
        }

        // 시간 부분
        if settings.showTime {
            components.append(getFormattedTime())
        }

        return components.joined(separator: " ")
    }

    /// 설정에 따른 날짜 문자열 생성 (요일 형식 포함 가능)
    private func getFormattedDate() -> String {
        let settings = SettingsManager.shared
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")

        // dateFormat에 요일(E), 날짜(M, d), 년도(y) 등 모두 포함 가능
        formatter.dateFormat = settings.dateFormat
        return formatter.string(from: Date())
    }

    /// 설정에 따른 시간 문자열 생성
    private func getFormattedTime() -> String {
        let settings = SettingsManager.shared
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")

        var formatString: String

        if settings.use24HourClock {
            // 24시간제
            formatString = settings.showSeconds ? "HH:mm:ss" : "HH:mm"
        } else {
            // 12시간제
            if settings.showAMPM {
                formatString = settings.showSeconds ? "a h:mm:ss" : "a h:mm"
            } else {
                formatString = settings.showSeconds ? "h:mm:ss" : "h:mm"
            }
        }

        formatter.dateFormat = formatString
        return formatter.string(from: Date())
    }
}
