// GoogleCalendarAPI.swift
// MiniCalendar
//
// Google Calendar API를 통한 공휴일 데이터 fetch

import Foundation

/// Google Calendar API 에러
enum GoogleCalendarAPIError: LocalizedError {
    case apiKeyNotFound
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case apiError(statusCode: Int, message: String)
    case decodingError(Error)

    var errorDescription: String? {
        switch self {
        case .apiKeyNotFound:
            return "API 키를 찾을 수 없습니다"
        case .invalidURL:
            return "잘못된 URL입니다"
        case .networkError(let error):
            return "네트워크 오류: \(error.localizedDescription)"
        case .invalidResponse:
            return "잘못된 응답입니다"
        case .apiError(let code, let message):
            return "API 오류 (\(code)): \(message)"
        case .decodingError(let error):
            return "디코딩 오류: \(error.localizedDescription)"
        }
    }
}

/// Google Calendar API 클라이언트
struct GoogleCalendarAPI {

    // MARK: - API 키

    /// Info.plist에서 API 키 로드
    static var apiKey: String {
        get throws {
            guard let key = Bundle.main.object(forInfoDictionaryKey: "GoogleCalendarAPIKey") as? String,
                  !key.isEmpty else {
                throw GoogleCalendarAPIError.apiKeyNotFound
            }
            return key
        }
    }

    // MARK: - 국가별 Calendar ID

    /// 지원하는 국가 목록
    static let supportedCountries: [(code: String, name: String)] = [
        ("KR", "한국"),
        ("US", "United States"),
        ("JP", "Japan"),
        ("CN", "China"),
        ("GB", "United Kingdom")
    ]

    /// 국가 코드에 해당하는 Google Calendar ID 반환
    static func calendarId(for countryCode: String) -> String {
        switch countryCode {
        case "KR":
            return "ko.south_korea#holiday@group.v.calendar.google.com"
        case "US":
            return "en.usa#holiday@group.v.calendar.google.com"
        case "JP":
            return "ja.japanese#holiday@group.v.calendar.google.com"
        case "CN":
            return "zh.china#holiday@group.v.calendar.google.com"
        case "GB":
            return "en.uk#holiday@group.v.calendar.google.com"
        default:
            // 기본값: 한국
            return "ko.south_korea#holiday@group.v.calendar.google.com"
        }
    }

    /// 국가 코드에 따른 언어 파라미터 (한국만 한글, 나머지 영문)
    static func languageCode(for countryCode: String) -> String {
        return countryCode == "KR" ? "ko" : "en"
    }

    // MARK: - API 호출

    /// 특정 국가/년도의 공휴일 데이터 fetch
    /// - Parameters:
    ///   - countryCode: 국가 코드 (KR, US, JP 등)
    ///   - year: 년도
    /// - Returns: 공휴일 배열
    static func fetchHolidays(countryCode: String, year: Int) async throws -> [Holiday] {
        let apiKey = try self.apiKey
        let calendarId = calendarId(for: countryCode).addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        let language = languageCode(for: countryCode)

        // 년도 범위 설정
        let timeMin = "\(year)-01-01T00:00:00Z"
        let timeMax = "\(year)-12-31T23:59:59Z"

        // URL 구성
        var components = URLComponents(string: "https://www.googleapis.com/calendar/v3/calendars/\(calendarId)/events")
        components?.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "timeMin", value: timeMin),
            URLQueryItem(name: "timeMax", value: timeMax),
            URLQueryItem(name: "singleEvents", value: "true"),
            URLQueryItem(name: "orderBy", value: "startTime"),
            URLQueryItem(name: "hl", value: language)
        ]

        guard let url = components?.url else {
            throw GoogleCalendarAPIError.invalidURL
        }

        // API 요청
        let (data, response) = try await URLSession.shared.data(from: url)

        // 응답 확인
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GoogleCalendarAPIError.invalidResponse
        }

        if httpResponse.statusCode != 200 {
            // 에러 메시지 추출 시도
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw GoogleCalendarAPIError.apiError(statusCode: httpResponse.statusCode, message: errorMessage)
        }

        // JSON 파싱
        do {
            let calendarResponse = try JSONDecoder().decode(GoogleCalendarResponse.self, from: data)
            return calendarResponse.items.compactMap { event -> Holiday? in
                guard let dateString = event.start.date else { return nil }

                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                formatter.timeZone = TimeZone.current  // 로컬 시간대 사용

                guard let date = formatter.date(from: dateString) else { return nil }

                return Holiday(
                    id: event.id,
                    date: date,
                    name: event.summary,
                    countryCode: countryCode
                )
            }
        } catch {
            throw GoogleCalendarAPIError.decodingError(error)
        }
    }
}

// MARK: - Google Calendar API 응답 모델

/// Google Calendar API 응답
private struct GoogleCalendarResponse: Decodable {
    let items: [GoogleCalendarEvent]
}

/// Google Calendar 이벤트
private struct GoogleCalendarEvent: Decodable {
    let id: String
    let summary: String
    let start: GoogleCalendarEventDate
}

/// Google Calendar 이벤트 날짜
private struct GoogleCalendarEventDate: Decodable {
    let date: String?       // 종일 이벤트 (공휴일)
    let dateTime: String?   // 시간 지정 이벤트
}
