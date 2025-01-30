import Foundation

public enum SamplingRate: String, CaseIterable {
    case accurate = "Accurate"
    case balanced = "Balanced"
    case efficient = "Efficient"
    
    var description: String {
        switch self {
        case .accurate: return "~5h battery"
        case .balanced: return "~8h battery"
        case .efficient: return "~12h battery"
        }
    }
    
    var recordingTime: String {
        switch self {
        case .accurate: return "4-5 hours"
        case .balanced: return "7-8 hours"
        case .efficient: return "10-12 hours"
        }
    }
    
    var saveInterval: TimeInterval {
        switch self {
        case .accurate: return 5
        case .balanced: return 10
        case .efficient: return 15
        }
    }
    
    var motionInterval: TimeInterval {
        switch self {
        case .accurate: return 1
        case .balanced: return 5
        case .efficient: return 10
        }
    }
    
    var heartRateInterval: TimeInterval {
        switch self {
        case .accurate: return 5
        case .balanced: return 10
        case .efficient: return 15
        }
    }
} 
