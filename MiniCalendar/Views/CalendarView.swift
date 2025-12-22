// CalendarView.swift
// MiniCalendar
//
// 달력 메인 뷰

import SwiftUI
import AppKit

struct CalendarView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @State private var displayedMonth: Date = Date()

    var body: some View {
        VStack(spacing: 10) {
            // 헤더 (년/월, 네비게이션)
            CalendarHeaderView(displayedMonth: $displayedMonth)

            // 요일 헤더
            WeekdayHeaderView()

            // 날짜 그리드
            CalendarGridView(displayedMonth: displayedMonth)

            Spacer()
        }
        .padding(12)
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
        .frame(width: 280, height: 300)
}
