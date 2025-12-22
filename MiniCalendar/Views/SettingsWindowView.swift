// SettingsWindowView.swift
// MiniCalendar
//
// 독립 설정 윈도우용 뷰

import SwiftUI

struct SettingsWindowView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @State private var showFormatHelp: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // 일반 섹션
                    SettingsSection(title: "General") {
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
                    SettingsSection(title: "Time options") {
                        SettingsToggleRow(
                            title: "Show Time",
                            isOn: $settingsManager.showTime
                        )
                        SettingsToggleRow(
                            title: "Display the time with seconds",
                            isOn: $settingsManager.showSeconds
                        )
                        .opacity(settingsManager.showTime ? 1.0 : 0.4)
                        .disabled(!settingsManager.showTime)

                        SettingsToggleRow(
                            title: "Use a 24-hour clock",
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

                    // 날짜 옵션 섹션
                    SettingsSection(title: "Date options") {
                        SettingsToggleRow(
                            title: "Show date",
                            isOn: $settingsManager.showDate
                        )

                        HStack(spacing: 12) {
                            Text("Format")
                                .foregroundColor(.secondary)

                            TextField("M월 d일 (E)", text: $settingsManager.dateFormat)
                                .textFieldStyle(.plain)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color(nsColor: .textBackgroundColor))
                                .cornerRadius(6)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color(nsColor: .separatorColor), lineWidth: 1)
                                )

                            Button(action: {
                                showFormatHelp.toggle()
                            }) {
                                Image(systemName: "questionmark.circle.fill")
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 16))
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
                    SettingsSection(title: "Calendar") {
                        HStack {
                            Text("Week starts on")
                                .foregroundColor(.secondary)
                            Spacer()
                            Picker("", selection: $settingsManager.weekStartsOnMonday) {
                                Text("Sunday").tag(false)
                                Text("Monday").tag(true)
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 150)
                        }
                    }
                }
                .padding(24)
            }

            Divider()

            // 하단 버전 및 Quit 버튼
            VStack(spacing: 8) {
                Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)

                Button(action: {
                    NSApplication.shared.terminate(nil)
                }) {
                    Text("Quit")
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 12)
        }
        .frame(width: 340, height: 480)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

// MARK: - 설정 섹션

struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.secondary)
                .tracking(0.5)

            VStack(alignment: .leading, spacing: 10) {
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
        }
        .toggleStyle(.checkbox)
    }
}

// MARK: - 날짜 형식 도움말 뷰

struct FormatHelpView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Date Format")
                .font(.headline)

            VStack(alignment: .leading, spacing: 4) {
                Group {
                    FormatHelpRow(symbol: "E", description: "Day of week (short)", example: "Fri")
                    FormatHelpRow(symbol: "EEEE", description: "Day of week (full)", example: "Friday")
                }

                Divider().padding(.vertical, 6)

                Group {
                    FormatHelpRow(symbol: "yyyy", description: "Year (4 digits)", example: "2025")
                    FormatHelpRow(symbol: "yy", description: "Year (2 digits)", example: "25")
                    FormatHelpRow(symbol: "M", description: "Month", example: "1, 12")
                    FormatHelpRow(symbol: "MM", description: "Month (2 digits)", example: "01, 12")
                    FormatHelpRow(symbol: "d", description: "Day", example: "1, 31")
                    FormatHelpRow(symbol: "dd", description: "Day (2 digits)", example: "01, 31")
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 6) {
                Text("Examples")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                FormatExampleRow(format: "M월 d일 (E)", result: "12월 20일 (금)")
                FormatExampleRow(format: "E M월 d일", result: "금 12월 20일")
                FormatExampleRow(format: "yyyy-MM-dd", result: "2025-12-20")
                FormatExampleRow(format: "MM/dd E", result: "12/20 금")
            }
        }
        .padding(16)
        .frame(width: 300)
    }
}

struct FormatHelpRow: View {
    let symbol: String
    let description: String
    let example: String

    var body: some View {
        HStack(spacing: 8) {
            Text(symbol)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(.accentColor)
                .frame(width: 44, alignment: .leading)

            Text(description)
                .font(.system(size: 12))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(example)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
    }
}

struct FormatExampleRow: View {
    let format: String
    let result: String

    var body: some View {
        HStack(spacing: 8) {
            Text(format)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.accentColor)

            Image(systemName: "arrow.right")
                .font(.system(size: 10))
                .foregroundColor(.secondary.opacity(0.6))

            Text(result)
                .font(.system(size: 12))
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    SettingsWindowView()
        .environmentObject(SettingsManager.shared)
}
