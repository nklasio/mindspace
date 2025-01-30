import SwiftUI
import Charts

struct DashboardView: View {
    @State private var isProtectionEnabled = true
    @State private var showSettings = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    NightmareProtectionCard(isEnabled: $isProtectionEnabled)
                    SleepSummaryCard()
                    WeeklyStatsCard()
                    NightmareHistoryCard()
                }
                .padding()
            }
            .background(
                LinearGradient(
                    colors: [
                        .indigo.opacity(0.1),
                        .mint.opacity(0.1),
                        .purple.opacity(0.1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("MindScape")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gear")
                            .foregroundStyle(.primary)
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(showDevMode: showSettings)
            }
        }
    }
} 
