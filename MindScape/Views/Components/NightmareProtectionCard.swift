import SwiftUI

struct NightmareProtectionCard: View {
    @Binding var isEnabled: Bool
    @State private var showProtectionSettings = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: isEnabled ? "shield.lefthalf.filled" : "shield")
                    .font(.system(size: 24))
                    .symbolEffect(.bounce, options: .repeating, value: isEnabled)
                    .foregroundStyle(isEnabled ? .mint : .gray)
                
                VStack(alignment: .leading) {
                    Text(isEnabled ? "Protection Active" : "Protection Disabled")
                        .font(.headline)
                    Text(isEnabled ? "We're here for you" : "Enable to start protection")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Toggle("", isOn: $isEnabled)
                    .tint(.mint)
            }
            
            if isEnabled {
                Button {
                    showProtectionSettings = true
                } label: {
                    Text("Adjust Protection Settings")
                        .font(.subheadline)
                        .foregroundStyle(.mint)
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: isEnabled ? .mint.opacity(0.3) : .clear, radius: 8)
        )
        .sheet(isPresented: $showProtectionSettings) {
            ProtectionSettingsView()
        }
    }
} 