import SwiftUI

struct PrivacyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Privacy Policy")
                    .font(.title)
                    .fontWeight(.bold)
                
                Group {
                    Text("Data Collection")
                        .font(.headline)
                    Text("MindScape collects sleep-related data including heart rate, movement, and other biometric data through your Apple Watch. This data is used solely for nightmare detection and sleep quality analysis.")
                    
                    Text("Data Storage")
                        .font(.headline)
                    Text("All your data is stored locally on your device and optionally synced through iCloud. We do not have access to your personal data.")
                    
                    Text("Data Usage")
                        .font(.headline)
                    Text("Your data is used exclusively for providing the nightmare detection service and generating sleep quality insights. We do not share your data with third parties.")
                    
                    Text("Data Protection")
                        .font(.headline)
                    Text("We implement industry-standard security measures to protect your data. All sensitive data is encrypted both in transit and at rest.")
                }
                
                Spacer()
                
                Text("Last updated: January 2025")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
} 