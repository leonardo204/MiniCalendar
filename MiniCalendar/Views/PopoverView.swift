// PopoverView.swift
// MiniCalendar
//
// 팝오버 컨테이너 뷰

import SwiftUI

struct PopoverView: View {
    @EnvironmentObject var settingsManager: SettingsManager

    var body: some View {
        CalendarView()
            .frame(width: 280, height: 300)
    }
}

#Preview {
    PopoverView()
        .environmentObject(SettingsManager.shared)
}
