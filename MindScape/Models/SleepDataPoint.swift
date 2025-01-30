import Foundation

struct SleepDataPoint: Identifiable {
    let id = UUID()
    let time: Date
    let quality: Double
    let heartRate: Double
    let movement: Double
    
    static var sampleData: [SleepDataPoint] {
        let calendar = Calendar.current
        let now = Date()
        let startTime = calendar.date(byAdding: .hour, value: -8, to: now)!
        
        return stride(from: 0, to: 8*60, by: 15).map { minutes in
            let time = calendar.date(byAdding: .minute, value: minutes, to: startTime)!
            let quality = Double.random(in: 60...95)
            let heartRate = Double.random(in: 50...70)
            let movement = Double.random(in: 0...30)
            return SleepDataPoint(time: time, quality: quality, heartRate: heartRate, movement: movement)
        }
    }
} 