// CalendarView.swift
// MiniCalendar
//
// 달력 메인 뷰

import SwiftUI
import AppKit

struct CalendarView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var holidayService: HolidayService
    @State private var displayedMonth: Date = Date()

    /// 현재 표시 중인 년도
    private var displayedYear: Int {
        Calendar.current.component(.year, from: displayedMonth)
    }

    var body: some View {
        VStack(spacing: 0) {
            // 헤더 (년/월, 네비게이션)
            CalendarHeaderView(displayedMonth: $displayedMonth)
                .padding(.bottom, 14)

            // 요일 헤더
            WeekdayHeaderView()
                .padding(.bottom, 8)

            // 날짜 그리드
            CalendarGridView(displayedMonth: displayedMonth)

            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.top, 14)
        .padding(.bottom, 10)
        .background(
            ScrollWheelHandler { delta in
                withAnimation(.easeInOut(duration: 0.2)) {
                    if delta > 0 {
                        displayedMonth = displayedMonth.previousMonth
                    } else if delta < 0 {
                        displayedMonth = displayedMonth.nextMonth
                    }
                }
            }
        )
        .onReceive(NotificationCenter.default.publisher(for: .popoverWillShow)) { _ in
            // 팝업 열릴 때마다 현재 달로 리셋
            displayedMonth = Date()
        }
        .task {
            // 초기 로드: 현재 년도 공휴일
            await loadHolidaysIfNeeded()
        }
        .onChange(of: displayedYear) { newYear in
            // 년도 변경 시 해당 년도 공휴일 로드
            Task {
                await holidayService.loadHolidays(
                    countryCode: settingsManager.holidayCountryCode,
                    year: newYear
                )
            }
        }
        .onChange(of: settingsManager.holidayCountryCode) { newCountryCode in
            // 국가 변경 시 공휴일 다시 로드
            Task {
                await holidayService.changeCountry(to: newCountryCode)
            }
        }
    }

    /// 필요 시 공휴일 로드
    private func loadHolidaysIfNeeded() async {
        guard settingsManager.showHolidays else { return }
        await holidayService.loadHolidays(
            countryCode: settingsManager.holidayCountryCode,
            year: displayedYear
        )
    }
}

// MARK: - 스크롤 휠 핸들러

struct ScrollWheelHandler: NSViewRepresentable {
    var onScroll: (CGFloat) -> Void

    func makeNSView(context: Context) -> ScrollWheelNSView {
        let view = ScrollWheelNSView()
        view.onScroll = onScroll
        return view
    }

    func updateNSView(_ nsView: ScrollWheelNSView, context: Context) {
        nsView.onScroll = onScroll
    }
}

class ScrollWheelNSView: NSView {
    var onScroll: ((CGFloat) -> Void)?
    private var accumulatedDelta: CGFloat = 0
    private let threshold: CGFloat = 50.0 // 스크롤 임계값 (높을수록 덜 민감)
    private var lastScrollTime: Date = Date.distantPast
    private let cooldown: TimeInterval = 0.3 // 스크롤 간 최소 간격

    override func scrollWheel(with event: NSEvent) {
        // deltaY: 양수 = 위로 스크롤 (이전 월), 음수 = 아래로 스크롤 (다음 월)
        accumulatedDelta += event.scrollingDeltaY

        let now = Date()
        let timeSinceLastScroll = now.timeIntervalSince(lastScrollTime)

        if abs(accumulatedDelta) >= threshold && timeSinceLastScroll >= cooldown {
            onScroll?(accumulatedDelta)
            accumulatedDelta = 0
            lastScrollTime = now
        }

        // 이벤트 종료 시 누적값 리셋
        if event.phase == .ended || event.momentumPhase == .ended {
            accumulatedDelta = 0
        }
    }
}

#Preview {
    CalendarView()
        .environmentObject(SettingsManager.shared)
        .environmentObject(HolidayService.shared)
        .frame(width: 280, height: 300)
}
