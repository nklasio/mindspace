import AppIntents
import SwiftUI

struct StopSleepRecordingIntent: AppIntent {
    static var title: LocalizedStringResource = "Stop Sleep Recording"
    static var description: IntentDescription = IntentDescription(
        "Stops the current sleep recording",
        categoryName: "Sleep Tracking",
        searchKeywords: ["sleep", "stop", "tracking", "end"]
    )
    
    static var parameterSummary: some ParameterSummary {
        Summary("Stop current sleep recording")
    }

    func perform() async throws -> some IntentResult {
        print("StopSleepRecordingIntent: Performing")
        WatchConnectivityManager.shared.sendMessage([
            "command": "stopRecording"
        ])
        return .result()
    }
}
