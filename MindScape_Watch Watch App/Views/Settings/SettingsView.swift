import SwiftUI
import Foundation

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var samplingRate: SamplingRate
    @Binding var showDebugInfo: Bool
    
    var body: some View {
        NavigationStack {
            List {
                Section("Recording Quality") {
                    NavigationLink {
                        QualityPickerView(selection: $samplingRate)
                    } label: {
                        qualityRow(for: samplingRate)
                    }
                }
                
                Section {
                    HStack {
                        Image(systemName: "battery.100")
                            .foregroundStyle(qualityColor(for: samplingRate))
                        Text("Battery Impact: ")
                            .foregroundStyle(.secondary)
                        Text(samplingRate.description)
                            .foregroundStyle(qualityColor(for: samplingRate))
                    }
                    
                    HStack {
                        Image(systemName: "timer")
                            .foregroundStyle(qualityColor(for: samplingRate))
                        Text("Data Interval: ")
                            .foregroundStyle(.secondary)
                        Text("\(Int(samplingRate.saveInterval))s")
                            .foregroundStyle(qualityColor(for: samplingRate))
                    }
                } footer: {
                    VStack(alignment: .leading, spacing: 8) {
                        qualityExplanation(for: samplingRate)
                        Text("Higher quality uses more battery power but provides more detailed sleep data.")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section {
                    Toggle(isOn: $showDebugInfo) {
                        Label {
                            Text("Developer Mode")
                        } icon: {
                            Image(systemName: "hammer.fill")
                                .foregroundStyle(.orange)
                        }
                    }
                } footer: {
                    Text("Shows detailed sensor data for debugging purposes.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
} 