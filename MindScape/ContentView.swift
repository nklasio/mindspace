//
//  ContentView.swift
//  MindScape
//
//  Created by Niklas Stambor on 29.01.25.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import Charts

public enum TimeWindow {
    case hour, day, week, all
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Session.startTime, order: .reverse) private var sessions: [Session]
    @AppStorage("developerMode") private var developerMode = false
    @State private var showingExporter = false
    @State private var sessionToExport: Session?
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Dashboard Tab
            DashboardView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            // Settings Tab
            NavigationStack {
                SettingsView(showDevMode: true)
            }
            .tabItem {
                Label("Settings", systemImage: "slider.horizontal.3")
            }
            .tag(1)
            
            // Sessions List Tab (only shown in developer mode)
            if developerMode {
                NavigationStack {
                    SessionsListView()
                }
                .tabItem {
                    Label("Sessions", systemImage: "terminal.fill")
                }
                .tag(2)
            }
        }
        .tint(.mint) // Primary accent color
        .onAppear {
            // Style the tab bar
            let appearance = UITabBarAppearance()
            appearance.configureWithTransparentBackground()
            
            // Make background more translucent
            appearance.backgroundColor = .systemBackground.withAlphaComponent(0.5)
            
            // Use ultra thin material for maximum translucency
            appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
            
            // Add subtle shadow
            appearance.shadowColor = .clear
            
            // Style the selected item
            appearance.stackedLayoutAppearance.selected.iconColor = .systemMint
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor.systemMint
            ]
            
            // Style the normal items with more subtle colors
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor.secondaryLabel.withAlphaComponent(0.8)
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor.secondaryLabel.withAlphaComponent(0.8)
            ]
            
            // Apply the appearance
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

struct SessionDetailView: View {
    let session: Session
    @State private var showingExporter = false
    
    var body: some View {
        List {
            Section {
                HStack {
                    VStack(alignment: .leading) {
                        Text(session.startTime?.formatted(date: .abbreviated, time: .shortened) ?? "")
                        Text("to")
                        Text(session.endTime?.formatted(date: .abbreviated, time: .shortened) ?? "")
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        if let readings = session.readings {
                            Text("\(readings.count) samples")
                                .font(.caption)
                            if let avgHR = averageHeartRate {
                                Text("\(Int(avgHR)) BPM avg")
                                    .font(.caption)
                            }
                        }
                    }
                    .foregroundStyle(.secondary)
                }
            }
            
            Section("Heart Rate") {
                HeartRateChart(readings: session.readings ?? [])
                    .frame(height: 200)
            }
            
            Section {
                Chart {
                    ForEach(sortedReadings.filter { $0.oxygenLevel != nil }, id: \.self) { reading in
                        LineMark(
                            x: .value("Time", reading.timestamp ?? Date()),
                            y: .value("SpO₂", reading.oxygenLevel ?? 0)
                        )
                        .foregroundStyle(.blue)
                        .interpolationMethod(.catmullRom)
                        
                        AreaMark(
                            x: .value("Time", reading.timestamp ?? Date()),
                            y: .value("SpO₂", reading.oxygenLevel ?? 0)
                        )
                        .foregroundStyle(.blue.opacity(0.1))
                        .interpolationMethod(.catmullRom)
                        
                        if let selectedReading = selectedReading,
                           selectedReading.id == reading.id {
                            PointMark(
                                x: .value("Time", reading.timestamp ?? Date()),
                                y: .value("SpO₂", reading.oxygenLevel ?? 0)
                            )
                            .foregroundStyle(.blue)
                        }
                    }
                }
                .chartYScale(domain: 90...100)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .minute, count: 15)) { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel {
                                Text(date.formatted(date: .omitted, time: .shortened))
                            }
                        }
                    }
                }
                .frame(height: 200)
                .chartOverlay { proxy in
                    GeometryReader { geometry in
                        Rectangle()
                            .fill(.clear)
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        let x = value.location.x - geometry[proxy.plotAreaFrame].origin.x
                                        guard x >= 0, x <= geometry[proxy.plotAreaFrame].width else {
                                            return
                                        }
                                        
                                        let timestamp = proxy.value(atX: x, as: Date.self)
                                        if let timestamp {
                                            selectedReading = findClosestReading(to: timestamp)
                                        }
                                    }
                                    .onEnded { _ in
                                        selectedReading = nil
                                    }
                            )
                        
                        if let selectedReading = selectedReading {
                            let x = proxy.position(forX: selectedReading.timestamp ?? Date()) ?? 0
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(selectedReading.timestamp?.formatted(date: .abbreviated, time: .shortened) ?? "")
                                    .font(.caption2)
                                Text("\(Int(selectedReading.oxygenLevel ?? 0))% SpO₂")
                                    .foregroundStyle(.blue)
                                    .font(.caption.bold())
                            }
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(UIColor.systemBackground))
                                    .shadow(radius: 2)
                            )
                            .position(
                                x: min(max(x, 100), geometry.size.width - 100),
                                y: 40
                            )
                        }
                    }
                }
            } header: {
                Label("Blood Oxygen", systemImage: "lungs.fill")
                    .foregroundStyle(.blue)
            }
            
            Section("Motion") {
                MotionChart(readings: session.readings ?? [])
                    .frame(height: 250)
            }
        }
        .navigationTitle(session.startTime?.formatted(date: .abbreviated, time: .shortened) ?? "Session")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingExporter = true }) {
                    Label("Export", systemImage: "square.and.arrow.up")
                }
            }
        }
        .fileExporter(
            isPresented: $showingExporter,
            document: CSVDocument(sessions: [session]),
            contentType: UTType.commaSeparatedText,
            defaultFilename: "sleep_session_\(session.startTime?.formatted(date: .numeric, time: .omitted) ?? "export").csv"
        ) { result in
            switch result {
            case .success(let url):
                print("Saved to \(url)")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private var sortedReadings: [SensorReading] {
        session.readings?.sorted { ($0.timestamp ?? Date()) < ($1.timestamp ?? Date()) } ?? []
    }
    
    @State private var selectedReading: SensorReading?
    
    private func findClosestReading(to date: Date) -> SensorReading? {
        return sortedReadings.min(by: { 
            abs($0.timestamp?.timeIntervalSince(date) ?? .infinity) < 
            abs($1.timestamp?.timeIntervalSince(date) ?? .infinity) 
        })
    }
    
    private var averageHeartRate: Double? {
        guard let readings = session.readings, !readings.isEmpty else { return nil }
        let sum = readings.compactMap { $0.heartRate }.reduce(0, +)
        return sum / Double(readings.count)
    }
}

struct HeartRateChart: View {
    let readings: [SensorReading]
    @State private var selectedReading: SensorReading?
    @State private var selectedX: Double?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Chart(sortedReadings, id: \.timestamp) { reading in
                    LineMark(
                        x: .value("Time", reading.timestamp ?? Date()),
                        y: .value("BPM", reading.heartRate ?? 0)
                    )
                    .interpolationMethod(.linear)
                    
                    if let selectedReading = selectedReading,
                       selectedReading.id == reading.id {
                        PointMark(
                            x: .value("Time", reading.timestamp ?? Date()),
                            y: .value("BPM", reading.heartRate ?? 0)
                        )
                        .symbolSize(50)
                        .foregroundStyle(.white)
                        
                        RuleMark(
                            x: .value("Time", reading.timestamp ?? Date())
                        )
                        .foregroundStyle(Color.gray.opacity(0.3))
                    }
                }
                .chartYScale(domain: yRange)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .minute, count: 5)) { value in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.hour().minute())
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .chartOverlay { proxy in
                    GeometryReader { geometry in
                        Rectangle()
                            .fill(.clear)
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        let currentX = value.location.x
                                        if let timestamp: Date = proxy.value(atX: currentX) {
                                            selectedReading = findClosestReading(to: timestamp)
                                        }
                                    }
                                    .onEnded { _ in
                                        selectedReading = nil
                                    }
                            )
                    }
                }
                
                if let selectedReading = selectedReading {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(selectedReading.timestamp?.formatted(date: .abbreviated, time: .shortened) ?? "")
                            .font(.caption2)
                        Text("\(Int(selectedReading.heartRate ?? 0)) BPM")
                            .font(.caption.bold())
                    }
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(UIColor.systemBackground))
                            .shadow(radius: 2)
                    )
                    .position(
                        x: min(max(calculateTooltipPosition(for: selectedReading, in: geometry).x, 100),
                             geometry.size.width - 100),
                        y: 20
                    )
                }
            }
        }
    }
    
    private func findClosestReading(to date: Date) -> SensorReading? {
        return sortedReadings.min(by: { abs($0.timestamp?.timeIntervalSince(date) ?? .infinity) < abs($1.timestamp?.timeIntervalSince(date) ?? .infinity) })
    }
    
    private func calculateTooltipPosition(for reading: SensorReading, in geometry: GeometryProxy) -> CGPoint {
        let totalDuration = sortedReadings.last?.timestamp?.timeIntervalSince(sortedReadings.first?.timestamp ?? Date()) ?? 1
        let readingOffset = reading.timestamp?.timeIntervalSince(sortedReadings.first?.timestamp ?? Date()) ?? 0
        let xPosition = (readingOffset / totalDuration) * geometry.size.width
        return CGPoint(x: xPosition, y: 0)
    }
    
    var sortedReadings: [SensorReading] {
        readings.sorted { ($0.timestamp ?? Date()) < ($1.timestamp ?? Date()) }
    }
    
    var yRange: ClosedRange<Double> {
        let values = readings.compactMap { $0.heartRate }
        if values.isEmpty { return 40...180 }
        let min = values.min() ?? 40
        let max = values.max() ?? 180
        return Swift.min(min - 10, 40)...Swift.max(max + 10, 180)
    }
}

struct MotionChart: View {
    let readings: [SensorReading]
    @State private var selectedReading: SensorReading?
    @State private var selectedAxis: String = "rotation" // or "acceleration"
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Picker("Motion Type", selection: $selectedAxis) {
                    Text("Rotation").tag("rotation")
                    Text("Acceleration").tag("acceleration")
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                ZStack {
                    Chart(sortedReadings, id: \.timestamp) { reading in
                        let (x, y, z) = valuesForSelectedAxis(reading)
                        
                        LineMark(
                            x: .value("Time", reading.timestamp ?? Date()),
                            y: .value("Value", x)
                        )
                        .foregroundStyle(.red)
                        .interpolationMethod(.linear)
                        
                        if let selectedReading = selectedReading,
                           selectedReading.id == reading.id {
                            PointMark(
                                x: .value("Time", reading.timestamp ?? Date()),
                                y: .value("Value", x)
                            )
                            .symbolSize(50)
                            .foregroundStyle(.red)
                            
                            RuleMark(
                                x: .value("Time", reading.timestamp ?? Date())
                            )
                            .foregroundStyle(Color.gray.opacity(0.3))
                        }
                    }
                    .chartYScale(domain: yRange)
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .minute, count: 5)) { value in
                            AxisGridLine()
                            AxisValueLabel(format: .dateTime.hour().minute())
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading)
                    }
                    .chartOverlay { proxy in
                        GeometryReader { geometry in
                            Rectangle()
                                .fill(.clear)
                                .contentShape(Rectangle())
                                .gesture(
                                    DragGesture(minimumDistance: 0)
                                        .onChanged { value in
                                            let currentX = value.location.x
                                            if let timestamp: Date = proxy.value(atX: currentX) {
                                                selectedReading = findClosestReading(to: timestamp)
                                            }
                                        }
                                        .onEnded { _ in
                                            selectedReading = nil
                                        }
                                )
                        }
                    }
                    
                    if let selectedReading = selectedReading {
                        let (x, y, z) = valuesForSelectedAxis(selectedReading)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(selectedReading.timestamp?.formatted(date: .abbreviated, time: .shortened) ?? "")
                                .font(.caption2)
                            Text("X: \(String(format: "%.2f", x))")
                                .foregroundColor(.red)
                                .font(.caption.bold())
                            Text("Y: \(String(format: "%.2f", y))")
                                .foregroundColor(.green)
                                .font(.caption.bold())
                            Text("Z: \(String(format: "%.2f", z))")
                                .foregroundColor(.blue)
                                .font(.caption.bold())
                        }
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(UIColor.systemBackground))
                                .shadow(radius: 2)
                        )
                        .position(
                            x: min(max(calculateTooltipPosition(for: selectedReading, in: geometry).x, 100),
                                 geometry.size.width - 100),
                            y: 40
                        )
                    }
                }
            }
        }
    }
    
    private func valuesForSelectedAxis(_ reading: SensorReading) -> (Double, Double, Double) {
        if selectedAxis == "rotation" {
            return (reading.rotationX ?? 0, reading.rotationY ?? 0, reading.rotationZ ?? 0)
        } else {
            return (reading.accelerationX ?? 0, reading.accelerationY ?? 0, reading.accelerationZ ?? 0)
        }
    }
    
    var yRange: ClosedRange<Double> {
        if selectedAxis == "rotation" {
            let xValues = readings.compactMap { $0.rotationX }
            let yValues = readings.compactMap { $0.rotationY }
            let zValues = readings.compactMap { $0.rotationZ }
            let allValues = xValues + yValues + zValues
            
            if allValues.isEmpty { return -3...3 }
            let min = allValues.min() ?? -3
            let max = allValues.max() ?? 3
            let padding = (max - min) * 0.1 // Add 10% padding
            return Swift.min(min - padding, -3)...Swift.max(max + padding, 3)
        } else {
            let xValues = readings.compactMap { $0.accelerationX }
            let yValues = readings.compactMap { $0.accelerationY }
            let zValues = readings.compactMap { $0.accelerationZ }
            let allValues = xValues + yValues + zValues
            
            if allValues.isEmpty { return -0.5...0.5 }
            let min = allValues.min() ?? -0.5
            let max = allValues.max() ?? 0.5
            let padding = (max - min) * 0.1 // Add 10% padding
            return Swift.min(min - padding, -0.5)...Swift.max(max + padding, 0.5)
        }
    }
    
    private func findClosestReading(to date: Date) -> SensorReading? {
        return sortedReadings.min(by: { abs($0.timestamp?.timeIntervalSince(date) ?? .infinity) < abs($1.timestamp?.timeIntervalSince(date) ?? .infinity) })
    }
    
    var sortedReadings: [SensorReading] {
        readings.sorted { ($0.timestamp ?? Date()) < ($1.timestamp ?? Date()) }
    }
    
    private func calculateTooltipPosition(for reading: SensorReading, in geometry: GeometryProxy) -> CGPoint {
        let totalDuration = sortedReadings.last?.timestamp?.timeIntervalSince(sortedReadings.first?.timestamp ?? Date()) ?? 1
        let readingOffset = reading.timestamp?.timeIntervalSince(sortedReadings.first?.timestamp ?? Date()) ?? 0
        let xPosition = (readingOffset / totalDuration) * geometry.size.width
        return CGPoint(x: xPosition, y: 0)
    }
}

struct CSVDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.commaSeparatedText] }
    
    var sessions: [Session]
    
    init(sessions: [Session]) {
        self.sessions = sessions
    }
    
    init(configuration: ReadConfiguration) throws {
        sessions = []
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let headers = "Session,Timestamp,Heart Rate,Oxygen Level,Rotation X,Rotation Y,Rotation Z,Acceleration X,Acceleration Y,Acceleration Z\n"
        var rows: [String] = []
        
        for session in sessions {
            guard let readings = session.readings else { continue }
            for reading in readings {
                let row = "\(session.name ?? ""),\(reading.timestamp?.ISO8601Format() ?? ""),\(reading.heartRate ?? 0),\(reading.oxygenLevel ?? 0),\(reading.rotationX ?? 0),\(reading.rotationY ?? 0),\(reading.rotationZ ?? 0),\(reading.accelerationX ?? 0),\(reading.accelerationY ?? 0),\(reading.accelerationZ ?? 0)"
                rows.append(row)
            }
        }
        
        let csvString = headers + rows.joined(separator: "\n")
        let data = csvString.data(using: .utf8)!
        return FileWrapper(regularFileWithContents: data)
    }
}

extension View {
    func tooltip<Content: View>(
        isPresented: Bool,
        position: CGPoint,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.overlay {
            if isPresented {
                GeometryReader { geometry in
                    content()
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(UIColor.systemBackground))
                                .shadow(radius: 2)
                        )
                        .position(
                            x: min(max(position.x, 100), geometry.size.width - 100),
                            y: position.y + 40
                        )
                }
            }
        }
    }
}

#Preview {
    return ContentView()
        .modelContainer(previewContainerContentView)
}

@MainActor
private let previewContainerContentView: ModelContainer = {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: Session.self,
            SensorReading.self,
            configurations: config
        )
        
        // Create sample data
        let session1 = Session(
            startTime: Date().addingTimeInterval(-3600),
            endTime: Date(),
            isFavorite: true
        )
        
        // Add some sample readings
        let readings1 = [
            SensorReading(timestamp: Date().addingTimeInterval(-3600), heartRate: 65),
            SensorReading(timestamp: Date().addingTimeInterval(-1800), heartRate: 68),
            SensorReading(timestamp: Date(), heartRate: 62)
        ]
        
        container.mainContext.insert(session1)
        readings1.forEach { container.mainContext.insert($0) }
        
        return container
    } catch {
        fatalError("Failed to create preview container: \(error.localizedDescription)")
    }
}()

