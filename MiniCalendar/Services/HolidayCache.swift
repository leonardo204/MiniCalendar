// HolidayCache.swift
// MiniCalendar
//
// 공휴일 데이터 로컬 캐시 관리

import Foundation

/// 공휴일 캐시 에러
enum HolidayCacheError: LocalizedError {
    case directoryCreationFailed(Error)
    case saveFailed(Error)
    case loadFailed(Error)
    case deleteFailed(Error)

    var errorDescription: String? {
        switch self {
        case .directoryCreationFailed(let error):
            return "캐시 디렉토리 생성 실패: \(error.localizedDescription)"
        case .saveFailed(let error):
            return "캐시 저장 실패: \(error.localizedDescription)"
        case .loadFailed(let error):
            return "캐시 로드 실패: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "캐시 삭제 실패: \(error.localizedDescription)"
        }
    }
}

/// 공휴일 캐시 관리자
struct HolidayCache {

    // MARK: - 캐시 경로

    /// Application Support 내 holidays 폴더 경로
    static var cacheDirectory: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return appSupport.appendingPathComponent("MiniCalendar/holidays", isDirectory: true)
    }

    /// 캐시 파일 경로 (예: KR_2025.json)
    static func cacheFilePath(countryCode: String, year: Int) -> URL {
        return cacheDirectory.appendingPathComponent("\(countryCode)_\(year).json")
    }

    // MARK: - 캐시 디렉토리 생성

    /// 캐시 디렉토리가 없으면 생성
    static func ensureCacheDirectoryExists() throws {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            do {
                try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
            } catch {
                throw HolidayCacheError.directoryCreationFailed(error)
            }
        }
    }

    // MARK: - 캐시 존재 여부

    /// 특정 국가/년도 캐시 존재 여부
    static func exists(countryCode: String, year: Int) -> Bool {
        let filePath = cacheFilePath(countryCode: countryCode, year: year)
        return FileManager.default.fileExists(atPath: filePath.path)
    }

    // MARK: - 캐시 저장

    /// 공휴일 데이터를 캐시에 저장
    static func save(holidays: [Holiday], countryCode: String, year: Int) throws {
        try ensureCacheDirectoryExists()

        let cacheData = HolidayCacheData(
            countryCode: countryCode,
            year: year,
            fetchedAt: Date(),
            holidays: holidays
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601

        do {
            let data = try encoder.encode(cacheData)
            let filePath = cacheFilePath(countryCode: countryCode, year: year)
            try data.write(to: filePath)
        } catch {
            throw HolidayCacheError.saveFailed(error)
        }
    }

    // MARK: - 캐시 로드

    /// 캐시에서 공휴일 데이터 로드
    /// - Returns: 캐시된 공휴일 배열, 없으면 nil
    static func load(countryCode: String, year: Int) throws -> [Holiday]? {
        let filePath = cacheFilePath(countryCode: countryCode, year: year)

        guard FileManager.default.fileExists(atPath: filePath.path) else {
            return nil
        }

        do {
            let data = try Data(contentsOf: filePath)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let cacheData = try decoder.decode(HolidayCacheData.self, from: data)
            return cacheData.holidays
        } catch {
            throw HolidayCacheError.loadFailed(error)
        }
    }

    // MARK: - 캐시 삭제

    /// 특정 국가/년도 캐시 삭제
    static func delete(countryCode: String, year: Int) throws {
        let filePath = cacheFilePath(countryCode: countryCode, year: year)

        guard FileManager.default.fileExists(atPath: filePath.path) else {
            return
        }

        do {
            try FileManager.default.removeItem(at: filePath)
        } catch {
            throw HolidayCacheError.deleteFailed(error)
        }
    }

    /// 특정 국가의 모든 캐시 삭제 (새로고침용)
    static func deleteAll(countryCode: String) throws {
        try ensureCacheDirectoryExists()

        let fileManager = FileManager.default
        let files = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)

        for file in files {
            if file.lastPathComponent.hasPrefix("\(countryCode)_") {
                try fileManager.removeItem(at: file)
            }
        }
    }
}
