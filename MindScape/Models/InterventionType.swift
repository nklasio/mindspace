import Foundation

enum InterventionType: String, CaseIterable, Identifiable {
    case haptic
    case sound
    case both
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .haptic: return "Haptic Only"
        case .sound: return "Sound Only"
        case .both: return "Haptic & Sound"
        }
    }
} 