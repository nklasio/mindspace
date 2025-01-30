import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct SessionsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Session.startTime, order: .reverse) private var sessions: [Session]
    @State private var showingExporter = false
    @State private var sessionToExport: Session?
    
    var body: some View {
        List {
            ForEach(sessions) { session in
                NavigationLink {
                    SessionDetailView(session: session)
                } label: {
                    SessionRowView(session: session)
                }
                .swipeActions(edge: .leading) {
                    Button {
                        session.isFavorite?.toggle()
                        try? modelContext.save()
                    } label: {
                        if session.isFavorite == true {
                            Label("Unfavorite", systemImage: "star.slash")
                                .tint(.gray)
                        } else {
                            Label("Favorite", systemImage: "star.fill")
                                .tint(.yellow)
                        }
                    }
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button {
                        sessionToExport = session
                        showingExporter = true
                    } label: {
                        Label("Export", systemImage: "square.and.arrow.up")
                    }
                    .tint(.blue)
                    
                    Button(role: .destructive) {
                        modelContext.delete(session)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .navigationTitle("Sleep Sessions")
        .fileExporter(
            isPresented: $showingExporter,
            document: sessionToExport.map { CSVDocument(sessions: [$0]) } ?? CSVDocument(sessions: []),
            contentType: UTType.commaSeparatedText,
            defaultFilename: "sleep_session.csv"
        ) { result in
            if case .success(let url) = result {
                print("Saved to \(url)")
            }
            sessionToExport = nil
        }
    }
} 