import SwiftUI

struct ProtectionSettingsView: View {
    @AppStorage("interventionType") private var interventionType = InterventionType.haptic
    @AppStorage("interventionStrength") private var interventionStrength = 0.5
    @AppStorage("autoStopEnabled") private var autoStopEnabled = true
    @AppStorage("autoStopDuration") private var autoStopDuration = 60.0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Intervention Type Card
                SettingsCard(icon: "hand.raised.fill", title: "Intervention Type", color: .mint) {
                    Picker("", selection: $interventionType) {
                        ForEach(InterventionType.allCases) { type in
                            Text(type.description)
                                .tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.vertical, 8)
                    
                    HStack {
                        Image(systemName: interventionType.icon)
                            .foregroundStyle(.mint)
                        Text(interventionType.explanation)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Strength Card
                SettingsCard(icon: "dial.high.fill", title: "Intervention Strength", color: .orange) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "waveform.path")
                            Text(strengthDescription)
                                .foregroundStyle(.secondary)
                        }
                        .font(.caption)
                        
                        Slider(value: $interventionStrength, in: 0...1) { editing in
                            if !editing {
                                HapticManager.shared.preview(strength: interventionStrength)
                            }
                        }
                        .tint(.orange)
                        
                        Button {
                            HapticManager.shared.triggerIntervention(
                                type: interventionType,
                                strength: interventionStrength
                            )
                        } label: {
                            Label("Test Current Settings", systemImage: "play.circle.fill")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                        }
                        .buttonStyle(.bordered)
                        .tint(.orange)
                    }
                }
                
                // Auto-stop Card
                SettingsCard(icon: "timer", title: "Auto-stop Protection", color: .blue) {
                    VStack(alignment: .leading, spacing: 16) {
                        Toggle("Enable Auto-stop", isOn: $autoStopEnabled)
                            .tint(.blue)
                        
                        if autoStopEnabled {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Stop After")
                                    .fontWeight(.medium)
                                Text("Protection will automatically stop after \(Int(autoStopDuration)) minutes")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Slider(value: $autoStopDuration, in: 30...480, step: 30)
                                    .tint(.blue)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .background(
            LinearGradient(
                colors: [
                    .mint.opacity(0.1),
                    .orange.opacity(0.1),
                    .blue.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .navigationTitle("Protection Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var strengthDescription: String {
        switch interventionStrength {
        case 0..<0.3: return "Gentle intervention"
        case 0.3..<0.7: return "Moderate intervention"
        default: return "Strong intervention"
        }
    }
}

extension InterventionType {
    var icon: String {
        switch self {
        case .haptic: return "iphone.radiowaves.left.and.right"
        case .sound: return "speaker.wave.2.fill"
        case .both: return "bell.and.waves.left.and.right"
        }
    }
    
    var explanation: String {
        switch self {
        case .haptic: return "Uses gentle vibrations to help you transition out of the nightmare"
        case .sound: return "Plays calming sounds to help guide you to better sleep"
        case .both: return "Combines both haptic and sound feedback for maximum effectiveness"
        }
    }
}
