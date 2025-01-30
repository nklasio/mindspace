import SwiftUI
import UniformTypeIdentifiers
import SwiftData

#if os(iOS)
import UIKit
#endif

struct ExportView: View {
    @State private var showingShareSheet = false
    @State private var exportURL: URL?
    @Query private var sessions: [Session]
    
    var body: some View {
        List {
            Section {
                Button {
                    exportData()
                } label: {
                    Label("Export as CSV", systemImage: "doc.text")
                }
                
                Button {
                    exportJSON()
                } label: {
                    Label("Export as JSON", systemImage: "doc.text.fill")
                }
            }
            
            Section {
                Text("Export your sleep data for analysis or backup. The exported file will contain all your recorded sessions and measurements.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Export Data")
        .sheet(isPresented: $showingShareSheet, content: {
            if let url = exportURL {
                ShareSheet(items: [url])
            }
        })
    }
    
    private func exportData() {
        // Implementation for CSV export
        let csvString = generateCSV()
        saveAndShare(data: csvString.data(using: .utf8)!, filename: "sleep_data.csv")
    }
    
    private func exportJSON() {
        // Implementation for JSON export
        let jsonString = generateJSON()
        saveAndShare(data: jsonString.data(using: .utf8)!, filename: "sleep_data.json")
    }
    
    private func generateCSV() -> String {
        // Dummy implementation
        return "Date,Duration,Quality,Incidents\n"
    }
    
    private func generateJSON() -> String {
        // Dummy implementation
        return "{\"sessions\": []}"
    }
    
    private func saveAndShare(data: Data, filename: String) {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        try? data.write(to: url)
        exportURL = url
        showingShareSheet = true
    }
}

#if os(iOS)
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
#else
struct ShareSheet: View {
    let items: [Any]
    
    var body: some View {
        Text("Sharing not available")
    }
}
#endif 
