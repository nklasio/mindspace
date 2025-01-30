import SwiftUI
import SwiftData

struct DataManagementView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var sessions: [Session]
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        List {
            Section {
                HStack {
                    Text("Total Sessions")
                    Spacer()
                    Text("\(sessions.count)")
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("Storage Used")
                    Spacer()
                    Text(calculateStorageUsed())
                        .foregroundStyle(.secondary)
                }
            }
            
            Section {
                Button(role: .destructive) {
                    showingDeleteConfirmation = true
                } label: {
                    Label("Delete All Data", systemImage: "trash")
                }
            }
        }
        .navigationTitle("Data Management")
        .alert("Delete All Data?", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteAllData()
            }
        } message: {
            Text("This action cannot be undone. All your sleep records will be permanently deleted.")
        }
    }
    
    private func calculateStorageUsed() -> String {
        // Rough estimation
        let bytesPerSession = 1024 * 10 // 10KB per session
        let totalBytes = sessions.count * bytesPerSession
        
        if totalBytes < 1024 * 1024 {
            return String(format: "%.1f KB", Double(totalBytes) / 1024.0)
        } else {
            return String(format: "%.1f MB", Double(totalBytes) / (1024.0 * 1024.0))
        }
    }
    
    private func deleteAllData() {
        for session in sessions {
            modelContext.delete(session)
        }
        try? modelContext.save()
    }
} 