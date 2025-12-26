// Holiday.swift
// MiniCalendar
//
// 공휴일 데이터 모델

import Foundation

/// 공휴일 정보를 나타내는 모델
struct Holiday: Codable, Identifiable, Equatable {
    /// Google Calendar event ID
    let id: String

    /// 공휴일 날짜
    let date: Date

    /// 공휴일 이름 (한국: 한글, 기타: 영문)
    let name: String

    /// 국가 코드 (KR, US, JP 등)
    let countryCode: String

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case id
        case date
        case name
        case countryCode
    }

    init(id: String, date: Date, name: String, countryCode: String) {
        self.id = id
        self.date = date
        self.name = name
        self.countryCode = countryCode
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        countryCode = try container.decode(String.self, forKey: .countryCode)

        // 날짜는 yyyy-MM-dd 형식 문자열로 저장/로드 (로컬 시간대)
        let dateString = try container.decode(String.self, forKey: .date)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current

        guard let parsedDate = formatter.date(from: dateString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .date,
                in: container,
                debugDescription: "날짜 형식이 올바르지 않습니다: \(dateString)"
            )
        }
        date = parsedDate
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(countryCode, forKey: .countryCode)

        // 날짜를 yyyy-MM-dd 형식 문자열로 저장 (로컬 시간대)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        try container.encode(formatter.string(from: date), forKey: .date)
    }
}

// MARK: - 캐시용 컨테이너

/// 공휴일 캐시 데이터 컨테이너
struct HolidayCacheData: Codable {
    /// 국가 코드
    let countryCode: String

    /// 년도
    let year: Int

    /// 캐시 생성 시간
    let fetchedAt: Date

    /// 공휴일 목록
    let holidays: [Holiday]
}
