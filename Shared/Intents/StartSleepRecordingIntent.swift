import AppIntents
import SwiftUI

struct StartSleepRecordingIntent: AppIntent {
    static var title: LocalizedStringResource = "Start Sleep Recording"
    static var description: IntentDescription = IntentDescription(
        "Starts recording sleep data",
        categoryName: "Sleep Tracking",
        searchKeywords: ["sleep", "record", "tracking", "start"]
    )
    
    @Parameter(title: "Quality", default: .balanced)
    var quality: RecordingQuality
    
    static var parameterSummary: some ParameterSummary {
        Summary("Start sleep recording with \(\.$quality) quality")
    }
    
    func perform() async throws -> some IntentResult {
        print("StartSleepRecordingIntent: Performing with quality \(quality)")
        WatchConnectivityManager.shared.sendMessage([
            "command": "startRecording",
            "quality": quality.rawValue
        ])
        return .result()
    }
}

enum RecordingQuality: String, AppEnum {
    case accurate = "Accurate"
    case balanced = "Balanced"
    case efficient = "Efficient"
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Recording Quality"
    static var caseDisplayRepresentations: [RecordingQuality: DisplayRepresentation] = [
        .accurate: "Accurate (5h battery)",
        .balanced: "Balanced (8h battery)",
        .efficient: "Efficient (12h battery)"
    ]
    
    var samplingRate: SamplingRate {
        switch self {
        case .accurate: return .accurate
        case .balanced: return .balanced
        case .efficient: return .efficient
        }
    }
}
