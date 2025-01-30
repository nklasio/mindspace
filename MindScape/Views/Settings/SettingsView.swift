import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("hapticFeedbackEnabled") private var hapticFeedbackEnabled = true
    @AppStorage("interventionDelay") private var interventionDelay = 30.0
    @AppStorage("sensitivity") private var sensitivity = 0.7
    @AppStorage("developerMode") private var developerMode = false
    let showDevMode: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Protection Settings Card
                SettingsCard(icon: "shield.lefthalf.filled", title: "Protection", color: .mint) {
                    SettingsLink(
                        icon: "waveform.path.ecg.rectangle",
                        title: "Nightmare Protection",
                        subtitle: "Configure intervention settings",
                        color: .mint,
                        destination: ProtectionSettingsView()
                    )
                }
                
                // Notifications Card
                SettingsCard(icon: "bell.badge.fill", title: "Notifications", color: .blue) {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                    Toggle("Haptic Feedback", isOn: $hapticFeedbackEnabled)
                }
                
                // Detection Settings Card
                SettingsCard(icon: "waveform.path.ecg.rectangle", title: "Detection", color: .purple) {
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading) {
                            Text("Intervention Delay")
                                .fontWeight(.medium)
                            Text("Wait \(Int(interventionDelay)) seconds before intervention")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Slider(value: $interventionDelay, in: 0...60, step: 5)
                                .tint(.purple)
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Detection Sensitivity")
                                .fontWeight(.medium)
                            Text("Higher sensitivity may lead to more false positives")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Slider(value: $sensitivity, in: 0...1)
                                .tint(.purple)
                        }
                    }
                }
                
                // Data Management Card
                SettingsCard(icon: "externaldrive.fill", title: "Data", color: .indigo) {
                    SettingsLink(
                        icon: "folder.fill",
                        title: "Manage Data",
                        subtitle: "View and manage your sleep data",
                        color: .indigo,
                        destination: DataManagementView()
                    )
                    
                    SettingsLink(
                        icon: "square.and.arrow.up.fill",
                        title: "Export Data",
                        subtitle: "Export your data for analysis",
                        color: .indigo,
                        destination: ExportView()
                    )
                }
                
                // About Card
                SettingsCard(icon: "info.circle.fill", title: "About", color: .teal) {
                    SettingsLink(
                        icon: "hand.raised.fill",
                        title: "Privacy Policy",
                        subtitle: "Learn how we protect your data",
                        color: .teal,
                        destination: PrivacyView()
                    )
                    
                    Link(destination: URL(string: "https://mindscape.app/help")!) {
                        SettingsLinkRow(
                            icon: "questionmark.circle.fill",
                            title: "Help & Support",
                            subtitle: "Get help and learn more",
                            color: .teal
                        )
                    }
                    
                    if showDevMode {
                        Divider()
                        Toggle(isOn: $developerMode) {
                            HStack(spacing: 16) {
                                Image(systemName: "terminal.fill")
                                    .font(.system(size: 24))
                                    .foregroundStyle(.gray)
                                    .frame(width: 32)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Developer Mode")
                                        .fontWeight(.medium)
                                        .foregroundStyle(.primary)
                                    Text("Show raw session data")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .tint(.gray)
                    }
                    
                    HStack {
                        Text("Version")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
        }
        .background(
            LinearGradient(
                colors: [
                    .mint.opacity(0.1),
                    .purple.opacity(0.1),
                    .indigo.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .navigationTitle("Settings")
    }
}

struct SettingsCard<Content: View>: View {
    let icon: String
    let title: String
    let color: Color
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .symbolEffect(.bounce, options: .repeating)
                    .foregroundStyle(color)
                Text(title)
                    .font(.headline)
            }
            
            content
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: color.opacity(0.2), radius: 8)
        )
    }
}

struct SettingsLink<Destination: View>: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let destination: Destination
    
    var body: some View {
        NavigationLink {
            destination
        } label: {
            SettingsLinkRow(
                icon: icon,
                title: title,
                subtitle: subtitle,
                color: color
            )
        }
    }
}

struct SettingsLinkRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(color)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption2.weight(.bold))
                .foregroundStyle(.secondary)
        }
        .contentShape(Rectangle())
    }
} 