# MiniCalendar

macOS 메뉴 막대에서 날짜, 시간, 달력을 간편하게 확인할 수 있는 앱입니다.

![macOS](https://img.shields.io/badge/macOS-13.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## 주요 기능

- **메뉴 막대 날짜/시간 표시**: 시스템 시계를 대체하여 사용자 정의 형식으로 표시
- **미니 달력 팝업**: 클릭 시 깔끔한 달력 팝업 표시
- **스크롤 제스처**: 마우스 휠/트랙패드로 이전/다음 월 이동
- **연도 빠른 이동**: `<<`, `>>` 버튼으로 연도 단위 이동
- **다양한 설정 옵션**:
  - 시간 표시 (12/24시간제, 초 단위, AM/PM)
  - 날짜 형식 커스터마이징 (요일 포함 가능)
  - 주 시작 요일 설정 (일요일/월요일)
  - 로그인 시 자동 실행

## 스크린샷

### 메뉴 막대
메뉴 막대에 날짜와 시간이 표시됩니다.

### 달력 팝업
클릭하면 미니 달력이 나타납니다.

### 설정 화면
다양한 옵션을 설정할 수 있습니다.

## 설치 방법

### DMG 파일로 설치
1. [Releases](https://github.com/leonardo204/MiniCalendar/releases)에서 최신 DMG 파일 다운로드
2. DMG 파일을 열고 MiniCalendar.app을 Applications 폴더로 드래그
3. Applications에서 MiniCalendar 실행

### 소스 코드에서 빌드
```bash
# 저장소 클론
git clone https://github.com/leonardo204/MiniCalendar.git
cd MiniCalendar

# xcodegen 설치 (필요시)
brew install xcodegen

# Xcode 프로젝트 생성
xcodegen generate

# Xcode에서 열기
open MiniCalendar.xcodeproj
```

## 시스템 시계 숨기기

MiniCalendar를 시스템 시계 대신 사용하려면:

1. **시스템 설정** → **제어 센터** 열기
2. **시계** 항목 찾기
3. **메뉴 막대에서 보기** 끄기

앱 최초 실행 시 안내 팝업이 표시되며, "설정 열기" 버튼으로 바로 이동할 수 있습니다.

## 날짜 형식 예시

| 형식 | 결과 |
|------|------|
| `M월 d일 (E)` | 12월 20일 (금) |
| `yyyy년 M월 d일` | 2025년 12월 20일 |
| `yyyy-MM-dd` | 2025-12-20 |
| `E M/d` | 금 12/20 |

### 형식 기호
- `yyyy`: 년도 4자리
- `yy`: 년도 2자리
- `M`: 월 (1-12)
- `MM`: 월 2자리 (01-12)
- `d`: 일 (1-31)
- `dd`: 일 2자리 (01-31)
- `E`: 요일 짧게 (월, 화, ...)
- `EEEE`: 요일 전체 (월요일, 화요일, ...)

## 요구 사항

- macOS 13.0 (Ventura) 이상
- Apple Silicon 또는 Intel Mac

## 기술 스택

- Swift 5.9
- SwiftUI + AppKit
- xcodegen

## 라이선스

MIT License
