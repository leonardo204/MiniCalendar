// StatusBarManager.swift
// MiniCalendar
//
// 메뉴 막대 아이템 및 팝오버 관리

import AppKit
import SwiftUI
import Combine

// MARK: - Notification Names

extension Notification.Name {
    static let popoverWillShow = Notification.Name("popoverWillShow")
}

class StatusBarManager: ObservableObject {
    // 메뉴 막대 아이템
    private var statusItem: NSStatusItem?
    // 팝오버 (달력 표시용)
    private var popover: NSPopover?
    // 시간 업데이트 타이머
    private var timer: Timer?
    // 날짜/시간 서비스
    private let dateTimeService: DateTimeService
    // 설정 변경 구독
    private var cancellables = Set<AnyCancellable>()

    init() {
        self.dateTimeService = DateTimeService()
        setupStatusItem()
        setupPopover()
        startTimer()
        observeSettingsChanges()
    }

    deinit {
        timer?.invalidate()
        cancellables.removeAll()
    }

    // MARK: - Setup

    /// 메뉴 막대 아이템 설정
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.action = #selector(togglePopover)
            button.target = self
            updateStatusBarText()
        }
    }

    /// 팝오버 설정
    private func setupPopover() {
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 280, height: 300)
        popover?.behavior = .transient
        popover?.animates = true
        popover?.contentViewController = NSHostingController(
            rootView: PopoverView()
                .environmentObject(SettingsManager.shared)
                .environmentObject(HolidayService.shared)
        )
    }

    /// 타이머 시작 (시간 업데이트용)
    private func startTimer() {
        // 초 단위 표시 여부에 따라 업데이트 주기 결정
        let interval: TimeInterval = SettingsManager.shared.showSeconds ? 1.0 : 1.0

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.updateStatusBarText()
        }
        // RunLoop에 추가하여 UI 업데이트 시에도 동작하도록
        if let timer = timer {
            RunLoop.current.add(timer, forMode: .common)
        }
    }

    /// 설정 변경 감지
    private func observeSettingsChanges() {
        let settings = SettingsManager.shared

        // 모든 설정 변경 시 메뉴 막대 업데이트
        settings.objectWillChange
            .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateStatusBarText()
                self?.restartTimerIfNeeded()
            }
            .store(in: &cancellables)
    }

    // MARK: - Actions

    /// 메뉴 막대 텍스트 업데이트
    func updateStatusBarText() {
        guard let button = statusItem?.button else { return }

        if SettingsManager.shared.showOnlyIcon {
            button.title = ""
            button.image = NSImage(systemSymbolName: "calendar", accessibilityDescription: "Calendar")
            button.image?.size = NSSize(width: 16, height: 16)
        } else {
            button.image = nil

            // 메뉴 막대 텍스트 스타일 설정 (폰트 크기 증가)
            let text = dateTimeService.getFormattedDateTime()
            let attributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.monospacedDigitSystemFont(ofSize: 14, weight: .medium)
            ]
            button.attributedTitle = NSAttributedString(string: text, attributes: attributes)
        }
    }

    /// 팝오버 토글
    @objc private func togglePopover() {
        guard let button = statusItem?.button else { return }

        if let popover = popover {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                // 팝오버 표시 전 알림 (현재 달로 리셋용)
                NotificationCenter.default.post(name: .popoverWillShow, object: nil)
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                // 팝오버가 표시되면 포커스 설정
                popover.contentViewController?.view.window?.makeKey()
            }
        }
    }

    /// 초 표시 설정 변경 시 타이머 재시작
    private func restartTimerIfNeeded() {
        // 타이머 주기가 변경되어야 할 경우에만 재시작
        startTimer()
    }

    /// 타이머 재시작 (설정 변경 시 호출)
    func restartTimer() {
        timer?.invalidate()
        startTimer()
    }
}
