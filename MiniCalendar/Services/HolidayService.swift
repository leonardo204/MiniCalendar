// HolidayService.swift
// MiniCalendar
//
// 공휴일 데이터 관리 서비스

import Foundation
import SwiftUI

/// 공휴일 서비스 에러
enum HolidayServiceError: LocalizedError {
    case fetchFailed(Error)
    case cacheFailed(Error)

    var errorDescription: String? {
        switch self {
        case .fetchFailed(let error):
            return "공휴일 데이터 가져오기 실패: \(error.localizedDescription)"
        case .cacheFailed(let error):
            return "캐시 오류: \(error.localizedDescription)"
        }
    }
}

/// 공휴일 데이터 관리 서비스
@MainActor
class HolidayService: ObservableObject {

    // MARK: - 싱글톤

    static let shared = HolidayService()

    // MARK: - Published 속성

    /// 현재 로드된 공휴일 (날짜 문자열 -> Holiday 매핑)
    /// 키: "yyyy-MM-dd" 형식
    @Published private(set) var holidays: [String: Holiday] = [:]

    /// 로딩 상태
    @Published private(set) var isLoading: Bool = false

    /// 마지막 에러
    @Published private(set) var lastError: Error?

    // MARK: - 내부 상태

    /// 로드된 년도 추적 (국가코드_년도 형식)
    private var loadedYears: Set<String> = []

    // MARK: - 초기화

    private init() {}

    // MARK: - 공개 메서드

    /// 특정 국가/년도의 공휴일 로드 (캐시 우선)
    func loadHolidays(countryCode: String, year: Int) async {
        let key = "\(countryCode)_\(year)"

        // 이미 로드된 경우 스킵
        if loadedYears.contains(key) {
            return
        }

        isLoading = true
        lastError = nil

        do {
            // 캐시 확인
            if let cachedHolidays = try HolidayCache.load(countryCode: countryCode, year: year) {
                mergeHolidays(cachedHolidays)
                loadedYears.insert(key)
                isLoading = false
                return
            }

            // 캐시 없으면 API 호출
            let fetchedHolidays = try await GoogleCalendarAPI.fetchHolidays(countryCode: countryCode, year: year)

            // 캐시에 저장
            try HolidayCache.save(holidays: fetchedHolidays, countryCode: countryCode, year: year)

            // 메모리에 병합
            mergeHolidays(fetchedHolidays)
            loadedYears.insert(key)

        } catch {
            lastError = error
            print("공휴일 로드 실패: \(error.localizedDescription)")
        }

        isLoading = false
    }

    /// 공휴일 데이터 강제 새로고침
    func refreshHolidays(countryCode: String, year: Int) async {
        let key = "\(countryCode)_\(year)"

        isLoading = true
        lastError = nil

        do {
            // 기존 캐시 삭제
            try HolidayCache.delete(countryCode: countryCode, year: year)

            // 메모리에서도 해당 국가 공휴일 제거
            removeHolidays(countryCode: countryCode)
            loadedYears.remove(key)

            // API 호출
            let fetchedHolidays = try await GoogleCalendarAPI.fetchHolidays(countryCode: countryCode, year: year)

            // 캐시에 저장
            try HolidayCache.save(holidays: fetchedHolidays, countryCode: countryCode, year: year)

            // 메모리에 병합
            mergeHolidays(fetchedHolidays)
            loadedYears.insert(key)

        } catch {
            lastError = error
            print("공휴일 새로고침 실패: \(error.localizedDescription)")
        }

        isLoading = false
    }

    /// 특정 국가의 모든 캐시 삭제 후 현재 년도 새로고침
    func refreshAllHolidays(countryCode: String) async {
        isLoading = true
        lastError = nil

        do {
            // 해당 국가의 모든 캐시 삭제
            try HolidayCache.deleteAll(countryCode: countryCode)

            // 메모리에서 해당 국가 공휴일 제거
            removeHolidays(countryCode: countryCode)

            // 로드된 년도에서 해당 국가 제거
            loadedYears = loadedYears.filter { !$0.hasPrefix("\(countryCode)_") }

            // 현재 년도 다시 로드
            let currentYear = Calendar.current.component(.year, from: Date())
            let fetchedHolidays = try await GoogleCalendarAPI.fetchHolidays(countryCode: countryCode, year: currentYear)
            try HolidayCache.save(holidays: fetchedHolidays, countryCode: countryCode, year: currentYear)
            mergeHolidays(fetchedHolidays)
            loadedYears.insert("\(countryCode)_\(currentYear)")

        } catch {
            lastError = error
            print("공휴일 전체 새로고침 실패: \(error.localizedDescription)")
        }

        isLoading = false
    }

    /// 특정 날짜의 공휴일 조회
    func holiday(for date: Date) -> Holiday? {
        let key = dateKey(from: date)
        return holidays[key]
    }

    /// 캐시 존재 여부 확인
    func hasCachedData(countryCode: String, year: Int) -> Bool {
        return HolidayCache.exists(countryCode: countryCode, year: year)
    }

    /// 국가 변경 시 메모리 초기화 및 새 국가 로드
    func changeCountry(to countryCode: String) async {
        // 기존 데이터 초기화
        holidays.removeAll()
        loadedYears.removeAll()

        // 현재 년도 로드
        let currentYear = Calendar.current.component(.year, from: Date())
        await loadHolidays(countryCode: countryCode, year: currentYear)
    }

    // MARK: - 내부 메서드

    /// 날짜를 키 문자열로 변환
    private func dateKey(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current  // 로컬 시간대 사용
        return formatter.string(from: date)
    }

    /// 공휴일 배열을 딕셔너리에 병합
    private func mergeHolidays(_ newHolidays: [Holiday]) {
        for holiday in newHolidays {
            let key = dateKey(from: holiday.date)
            holidays[key] = holiday
        }
    }

    /// 특정 국가의 공휴일 제거
    private func removeHolidays(countryCode: String) {
        holidays = holidays.filter { $0.value.countryCode != countryCode }
    }
}
