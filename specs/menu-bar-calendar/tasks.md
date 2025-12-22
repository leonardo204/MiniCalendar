# 구현 작업 목록

## 1. 프로젝트 초기 설정

- [ ] 1.1 Xcode 프로젝트 생성
  - macOS App 프로젝트 생성 (Swift, SwiftUI)
  - Bundle Identifier 설정
  - Deployment Target: macOS 13.0
  - _요구사항: 5.1, 5.2, 5.3_

- [ ] 1.2 Info.plist 설정
  - LSUIElement = true 설정 (Dock 아이콘 숨기기)
  - 앱 이름, 버전 정보 설정
  - _요구사항: 4.1, 5.2_

- [ ] 1.3 기본 파일 구조 생성
  - Managers, Services, Models, Views, Extensions 폴더 생성
  - 빈 파일 생성하여 구조 잡기
  - _요구사항: 5.3_

---

## 2. 데이터 모델 및 설정 관리

- [ ] 2.1 Settings 모델 구현
  - Settings 구조체 생성 (Codable)
  - 모든 설정 속성 정의 (일반, 시간, 날짜, 달력 옵션)
  - 기본값 설정
  - _요구사항: 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8, 3.9, 3.10, 3.11, 3.12, 3.13, 3.14_

- [ ] 2.2 SettingsManager 구현
  - ObservableObject로 구현
  - UserDefaults 로드/저장 메서드
  - @Published 속성들로 설정 값 노출
  - 싱글톤 패턴 적용
  - _요구사항: 4.3, 4.4, 5.5_

- [ ] 2.3 SettingsManager 단위 테스트
  - 설정 저장/로드 테스트
  - 기본값 테스트
  - 설정 변경 시 저장 테스트
  - _요구사항: 4.3, 4.4_

---

## 3. 날짜/시간 서비스

- [ ] 3.1 Date 확장 구현
  - 월의 시작일/마지막일 계산
  - 해당 월의 모든 날짜 배열 생성
  - 이전/다음 월 계산
  - 오늘 날짜 비교
  - _요구사항: 2.2, 2.4_

- [ ] 3.2 CalendarDay 모델 구현
  - 날짜, 현재 월 여부, 오늘 여부 속성
  - Identifiable 프로토콜 준수
  - _요구사항: 2.2, 2.3_

- [ ] 3.3 DateTimeService 구현
  - 설정에 따른 날짜/시간 포맷팅
  - 24시간제/12시간제 지원
  - 초 단위 표시 옵션
  - AM/PM 표시 옵션
  - 요일, 날짜 형식 지원
  - _요구사항: 1.2, 1.3, 3.5, 3.6, 3.7, 3.8, 3.9, 3.10, 3.11_

- [ ] 3.4 DateTimeService 단위 테스트
  - 다양한 설정 조합에 따른 포맷팅 테스트
  - 24시간제/12시간제 테스트
  - 날짜 형식 테스트
  - _요구사항: 3.5, 3.6, 3.7, 3.8, 3.9, 3.10, 3.11_

---

## 4. 메뉴 막대 기능

- [ ] 4.1 AppDelegate 구현
  - NSApplicationDelegate 구현
  - applicationDidFinishLaunching에서 초기화
  - NSApp.setActivationPolicy(.accessory) 설정
  - applicationWillTerminate에서 설정 저장
  - _요구사항: 4.1, 4.2, 4.3_

- [ ] 4.2 StatusBarManager 기본 구현
  - NSStatusItem 생성 및 설정
  - 메뉴 막대에 텍스트/아이콘 표시
  - 클릭 이벤트 처리
  - _요구사항: 1.1, 1.6_

- [ ] 4.3 StatusBarManager 타이머 구현
  - Timer로 매초 시간 업데이트
  - 설정에 따른 업데이트 주기 조정 (초 표시 시 1초, 아니면 1분)
  - _요구사항: 1.2, 1.3_

- [ ] 4.4 StatusBarManager 설정 연동
  - SettingsManager 변경 감지
  - 설정에 따른 메뉴 막대 표시 업데이트
  - 아이콘만 표시 옵션 지원
  - _요구사항: 1.4, 1.5, 1.6_

---

## 5. 팝오버 및 달력 UI

- [ ] 5.1 NSPopover 설정
  - StatusBarManager에 NSPopover 추가
  - 팝오버 토글 기능
  - 외부 클릭 시 닫기
  - _요구사항: 2.1, 2.5_

- [ ] 5.2 CalendarHeaderView 구현
  - 년/월 표시
  - 이전/다음 월 네비게이션 버튼
  - 설정 버튼 (기어 아이콘)
  - _요구사항: 2.2, 2.4_

- [ ] 5.3 WeekdayHeaderView 구현
  - 요일 헤더 표시 (일~토 또는 월~일)
  - weekStartsOnMonday 설정 반영
  - _요구사항: 3.12, 3.13, 3.14_

- [ ] 5.4 CalendarGridView 구현
  - 6주 x 7일 그리드 레이아웃
  - 이전/다음 월 날짜 흐리게 표시
  - _요구사항: 2.2_

- [ ] 5.5 DayCell 구현
  - 개별 날짜 셀 디자인
  - 오늘 날짜 빨간색 원형 배경으로 강조
  - 클릭 이벤트 없음 (보기 전용)
  - _요구사항: 2.3, 2.6_

- [ ] 5.6 CalendarView 통합
  - 모든 서브 뷰 조합
  - 월 네비게이션 상태 관리
  - _요구사항: 2.1, 2.2, 2.3, 2.4_

---

## 6. 설정 화면

- [ ] 6.1 SettingsView 기본 레이아웃
  - Form 기반 설정 화면
  - 섹션별 구분 (General, Time options, Date options, Calendar options)
  - _요구사항: 3.1_

- [ ] 6.2 General 섹션 구현
  - Open at Login 토글
  - Classic Calendar Appearance 토글
  - Show Only Icon 토글
  - _요구사항: 3.2, 3.3, 3.4_

- [ ] 6.3 Time options 섹션 구현
  - Show Time 토글
  - Display the time with seconds 토글
  - Use a 24-hour clock 토글
  - Show AM/PM 토글 (24시간제 비활성화 시만 활성)
  - _요구사항: 3.5, 3.6, 3.7, 3.8_

- [ ] 6.4 Date options 섹션 구현
  - Show the day of the week 토글
  - Show date 토글
  - Format 텍스트 필드
  - _요구사항: 3.9, 3.10, 3.11_

- [ ] 6.5 Calendar options 섹션 구현
  - Week starts on 선택 (Sunday/Monday)
  - Picker 또는 Segmented Control 사용
  - _요구사항: 3.12, 3.13, 3.14_

- [ ] 6.6 하단 버튼 구현
  - Quit 버튼 (앱 종료)
  - 설정 화면과 달력 화면 전환
  - _요구사항: 4.2_

---

## 7. 로그인 시 자동 실행

- [ ] 7.1 SMAppService 연동
  - ServiceManagement 프레임워크 import
  - SMAppService.mainApp.register() / unregister() 구현
  - 에러 처리
  - _요구사항: 3.2_

- [ ] 7.2 SettingsManager에 Launch at Login 연동
  - openAtLogin 속성 변경 시 SMAppService 호출
  - 현재 상태 동기화
  - _요구사항: 3.2_

---

## 8. 다크 모드 및 UI 마무리

- [ ] 8.1 다크 모드 지원
  - 시스템 색상 사용 확인
  - 다크/라이트 모드 전환 테스트
  - _요구사항: 4.5_

- [ ] 8.2 Color 확장 구현
  - 앱 전용 색상 정의 (필요시)
  - 오늘 날짜 강조 색상
  - _요구사항: 2.3, 4.5_

- [ ] 8.3 클래식 달력 모양 구현
  - classicAppearance 옵션에 따른 스타일 분기
  - 대체 UI 스타일 적용
  - _요구사항: 3.3_

---

## 9. 통합 및 최종 테스트

- [ ] 9.1 앱 생명주기 테스트
  - 앱 시작 → 설정 로드 확인
  - 앱 종료 → 설정 저장 확인
  - 재시작 시 설정 복원 확인
  - _요구사항: 4.3, 4.4_

- [ ] 9.2 전체 기능 통합 테스트
  - 메뉴 막대 표시 확인
  - 팝오버 동작 확인
  - 설정 변경 → UI 반영 확인
  - _요구사항: 전체_

- [ ] 9.3 앱 아이콘 추가
  - Assets.xcassets에 AppIcon 추가
  - 메뉴 막대용 아이콘 (16x16, 32x32) 추가
  - _요구사항: 1.6_
