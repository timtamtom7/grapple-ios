import SwiftUI

struct MacSettingsView: View {
    @AppStorage("debateStyle") private var debateStyle: String = "rigorous"
    @AppStorage("autoSave") private var autoSave: Bool = true
    @AppStorage("showSeverity") private var showSeverity: Bool = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                Text("Settings")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(MacTheme.primaryText)

                // Debate Style
                VStack(alignment: .leading, spacing: 12) {
                    Text("DEBATE STYLE")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(MacTheme.secondaryText)

                    VStack(spacing: 1) {
                        ForEach(["rigorous", "moderate", "friendly"], id: \.self) { style in
                            MacSettingsRow(
                                title: style.capitalized,
                                subtitle: styleDescription(style),
                                isSelected: debateStyle == style
                            ) {
                                debateStyle = style
                            }
                        }
                    }
                    .background(MacTheme.surface)
                    .cornerRadius(MacTheme.cornerRadius)
                }

                // Preferences
                VStack(alignment: .leading, spacing: 12) {
                    Text("PREFERENCES")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(MacTheme.secondaryText)

                    VStack(spacing: 1) {
                        MacSettingsToggle(
                            title: "Auto-save sessions",
                            subtitle: "Automatically save debates to history",
                            isOn: $autoSave
                        )
                        Divider().background(MacTheme.divider)
                        MacSettingsToggle(
                            title: "Show severity indicators",
                            subtitle: "Display challenge strength (1-3 dots)",
                            isOn: $showSeverity
                        )
                    }
                    .background(MacTheme.surface)
                    .cornerRadius(MacTheme.cornerRadius)
                }

                // Data Export
                VStack(alignment: .leading, spacing: 12) {
                    Text("DATA")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(MacTheme.secondaryText)

                    VStack(spacing: 1) {
                        Button {
                            exportData()
                        } label: {
                            MacSettingsButtonRow(title: "Export All Sessions", icon: "square.and.arrow.up")
                        }
                        Divider().background(MacTheme.divider)
                        Button {
                            exportData()
                        } label: {
                            MacSettingsButtonRow(title: "Export as PDF", icon: "doc.richtext")
                        }
                    }
                    .background(MacTheme.surface)
                    .cornerRadius(MacTheme.cornerRadius)
                }

                Spacer()
            }
            .padding(24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(MacTheme.background)
    }

    private func styleDescription(_ style: String) -> String {
        switch style {
        case "rigorous": return "Maximum pushback, no holds barred"
        case "moderate": return "Balanced challenge with fair points"
        case "friendly": return "Supportive pushback, constructive tone"
        default: return ""
        }
    }

    private func exportData() {
        // TODO: Implement export
    }
}

struct MacSettingsRow: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14))
                        .foregroundColor(MacTheme.primaryText)
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(MacTheme.secondaryText)
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(MacTheme.rebuttal)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }
}

struct MacSettingsToggle: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(MacTheme.primaryText)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(MacTheme.secondaryText)
            }
        }
        .toggleStyle(.switch)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

struct MacSettingsButtonRow: View {
    let title: String
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundColor(MacTheme.rebuttal)
                .frame(width: 20)
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(MacTheme.primaryText)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 11))
                .foregroundColor(MacTheme.divider)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#Preview {
    MacSettingsView()
}
