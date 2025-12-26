// PopoverView.swift
// MiniCalendar
//
// 팝오버 컨테이너 뷰

import SwiftUI

struct PopoverView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var holidayService: HolidayService

    var body: some View {
        CalendarView()
            .frame(width: 280, height: 300)
    }
}

#Preview {
    PopoverView()
        .environmentObject(SettingsManager.shared)
        .environmentObject(HolidayService.shared)
}
