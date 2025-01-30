import Foundation

struct TimeFormatter {
    static let shared = TimeFormatter()
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
    
    private let dateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    let parseFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
    
    func formatTime(_ timeString: String) -> String {
        if let date = parseFormatter.date(from: timeString) {
            return timeFormatter.string(from: date)
        }
        return timeString
    }
    
    func formatTime(_ date: Date) -> String {
        timeFormatter.string(from: date)
    }
    
    func formatDateTime(_ date: Date) -> String {
        dateTimeFormatter.string(from: date)
    }
    
    func formatTimeRange(from startTime: String, duration: Int) -> String? {
        guard let startDate = parseFormatter.date(from: startTime) else { return nil }
        let endDate = Calendar.current.date(byAdding: .minute, value: duration, to: startDate)
        return timeFormatter.string(from: endDate ?? startDate)
    }
} 