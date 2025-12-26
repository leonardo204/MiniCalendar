// SettingsWindowView.swift
// MiniCalendar
//
// 설정 윈도우 뷰

import SwiftUI

struct SettingsWindowView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var holidayService: HolidayService
    @State private var showFormatHelp: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // 설정 내용 (스크롤 없음)
            VStack(alignment: .leading, spacing: 20) {
                // 일반 섹션
                SettingsSection(title: "GENERAL") {
                    SettingsToggleRow(
                        title: "Open at Login",
                        isOn: $settingsManager.openAtLogin
                    )
                    SettingsToggleRow(
                        title: "Show Only Icon",
                        isOn: $settingsManager.showOnlyIcon
                    )
                }

                // 시간 옵션 섹션
                SettingsSection(title: "TIME") {
                    HStack(alignment: .top, spacing: 0) {
                        // 왼쪽 열
                        VStack(alignment: .leading, spacing: 8) {
                            SettingsToggleRow(
                                title: "Show Time",
                                isOn: $settingsManager.showTime
                            )
                            SettingsToggleRow(
                                title: "Show Seconds",
                                isOn: $settingsManager.showSeconds
                            )
                            .opacity(settingsManager.showTime ? 1.0 : 0.4)
                            .disabled(!settingsManager.showTime)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        // 오른쪽 열
                        VStack(alignment: .leading, spacing: 8) {
                            SettingsToggleRow(
                                title: "24-hour",
                                isOn: $settingsManager.use24HourClock
                            )
                            .opacity(settingsManager.showTime ? 1.0 : 0.4)
                            .disabled(!settingsManager.showTime)
                            SettingsToggleRow(
                                title: "Show AM/PM",
                                isOn: $settingsManager.showAMPM
                            )
                            .opacity(settingsManager.showTime && !settingsManager.use24HourClock ? 1.0 : 0.4)
                            .disabled(!settingsManager.showTime || settingsManager.use24HourClock)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                // 날짜 옵션 섹션
                SettingsSection(title: "DATE") {
                    SettingsToggleRow(
                        title: "Show Date",
                        isOn: $settingsManager.showDate
                    )

                    HStack(spacing: 8) {
                        Text("Format")
                            .foregroundColor(.secondary)
                            .frame(width: 50, alignment: .leading)

                        TextField("M월 d일 (E)", text: $settingsManager.dateFormat)
                            .textFieldStyle(.plain)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(Color(nsColor: .textBackgroundColor))
                            .cornerRadius(5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color(nsColor: .separatorColor), lineWidth: 1)
                            )

                        Button(action: { showFormatHelp.toggle() }) {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                        .popover(isPresented: $showFormatHelp, arrowEdge: .trailing) {
                            FormatHelpView()
                        }
                    }
                    .opacity(settingsManager.showDate ? 1.0 : 0.4)
                    .disabled(!settingsManager.showDate)
                }

                // 달력 옵션 섹션
                SettingsSection(title: "CALENDAR") {
                    HStack {
                        Text("Week starts on")
                            .foregroundColor(.secondary)
                        Spacer()
                        Picker("", selection: $settingsManager.weekStartsOnMonday) {
                            Text("Sun").tag(false)
                            Text("Mon").tag(true)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 100)
                    }
                }

                // 공휴일 옵션 섹션
                SettingsSection(title: "HOLIDAYS") {
                    SettingsToggleRow(
                        title: "Show Holidays",
                        isOn: $settingsManager.showHolidays
                    )

                    HStack {
                        Text("Country")
                            .foregroundColor(.secondary)
                        Spacer()
                        Picker("", selection: $settingsManager.holidayCountryCode) {
                            ForEach(GoogleCalendarAPI.supportedCountries, id: \.code) { country in
                                Text(country.name).tag(country.code)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(width: 140)
                    }
                    .opacity(settingsManager.showHolidays ? 1.0 : 0.4)
                    .disabled(!settingsManager.showHolidays)

                    HStack {
                        Spacer()
                        Button(action: refreshHolidays) {
                            HStack(spacing: 4) {
                                if holidayService.isLoading {
                                    ProgressView()
                                        .scaleEffect(0.7)
                                        .frame(width: 12, height: 12)
                                } else {
                                    Image(systemName: "arrow.clockwise")
                                }
                                Text("Refresh")
                            }
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(.accentColor)
                        .disabled(!settingsManager.showHolidays || holidayService.isLoading)
                        .opacity(settingsManager.showHolidays ? 1.0 : 0.4)
                    }
                }
            }
            .padding(20)

            Spacer()

            Divider()

            // 하단 버전 및 Quit 버튼
            HStack {
                Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0") (\(buildDate))")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)

                Spacer()

                Button(action: {
                    NSApplication.shared.terminate(nil)
                }) {
                    Text("Quit")
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .frame(width: 340, height: 520)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    /// 공휴일 새로고침
    private func refreshHolidays() {
        Task {
            await holidayService.refreshAllHolidays(countryCode: settingsManager.holidayCountryCode)
        }
    }

    /// 빌드 날짜
    private var buildDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let infoPath = Bundle.main.path(forResource: "Info", ofType: "plist"),
           let infoAttr = try? FileManager.default.attributesOfItem(atPath: infoPath),
           let date = infoAttr[.modificationDate] as? Date {
            return formatter.string(from: date)
        }
        return formatter.string(from: Date())
    }
}

// MARK: - 설정 섹션

struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.secondary)
                .tracking(0.5)

            VStack(alignment: .leading, spacing: 8) {
                content
            }
        }
    }
}

// MARK: - 설정 토글 행

struct SettingsToggleRow: View {
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            Text(title)
                .font(.system(size: 13))
        }
        .toggleStyle(.checkbox)
    }
}

// MARK: - 날짜 형식 도움말 뷰

struct FormatHelpView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Date Format")
                .font(.headline)

            VStack(alignment: .leading, spacing: 3) {
                FormatHelpRow(symbol: "E", description: "Day (short)", example: "Fri")
                FormatHelpRow(symbol: "EEEE", description: "Day (full)", example: "Friday")
                FormatHelpRow(symbol: "M", description: "Month", example: "12")
                FormatHelpRow(symbol: "MM", description: "Month (2 digits)", example: "01")
                FormatHelpRow(symbol: "d", description: "Day", example: "5")
                FormatHelpRow(symbol: "dd", description: "Day (2 digits)", example: "05")
                FormatHelpRow(symbol: "yyyy", description: "Year", example: "2025")
            }

            Divider()

            VStack(alignment: .leading, spacing: 4) {
                Text("Examples")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                FormatExampleRow(format: "M월 d일 (E)", result: "12월 20일 (금)")
                FormatExampleRow(format: "yyyy-MM-dd", result: "2025-12-20")
            }
        }
        .padding(12)
        .frame(width: 260)
    }
}

struct FormatHelpRow: View {
    let symbol: String
    let description: String
    let example: String

    var body: some View {
        HStack(spacing: 6) {
            Text(symbol)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(.accentColor)
                .frame(width: 36, alignment: .leading)

            Text(description)
                .font(.system(size: 11))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(example)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
    }
}

struct FormatExampleRow: View {
    let format: String
    let result: String

    var body: some View {
        HStack(spacing: 6) {
            Text(format)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.accentColor)

            Image(systemName: "arrow.right")
                .font(.system(size: 9))
                .foregroundColor(.secondary.opacity(0.6))

            Text(result)
                .font(.system(size: 11))
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    SettingsWindowView()
        .environmentObject(SettingsManager.shared)
        .environmentObject(HolidayService.shared)
}
