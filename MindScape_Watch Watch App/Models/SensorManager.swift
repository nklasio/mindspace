import SwiftUI
import CoreMotion
import HealthKit
import SwiftData

class SensorManager: ObservableObject {
    @Published var heartRate: Double = 0
    @Published var rotationRate: CMRotationRate = .init()
    @Published var userAcceleration: CMAcceleration = .init()
    
    private let healthStore = HKHealthStore()
    private let motionManager = CMMotionManager()
    private var workoutSession: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?
    private var timer: Timer?
    private var samplingRate: SamplingRate = .balanced
    private var currentSession: Session?
    private weak var modelContext: ModelContext?
    
    init() {
        // Request authorization for health data
        let heartRateType = HKQuantityType(.heartRate)
        healthStore.requestAuthorization(toShare: [], read: [heartRateType]) { success, error in
            if !success {
                print("Failed to get authorization: \(String(describing: error))")
            }
        }
        
        setupMotionUpdates()
        setupTimer(interval: samplingRate.saveInterval)
    }
    
    private func setupMotionUpdates() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = samplingRate.motionInterval
            motionManager.showsDeviceMovementDisplay = false
        }
    }
    
    private func startHeartRateQuery() {
        let heartRateType = HKQuantityType(.heartRate)
        
        // Configure heart rate query for better battery efficiency
        let heartRateConfig = HKWorkoutConfiguration()
        heartRateConfig.activityType = .mindAndBody
        heartRateConfig.locationType = .indoor
        
        let query = HKAnchoredObjectQuery(
            type: heartRateType,
            predicate: nil,
            anchor: nil,
            limit: HKObjectQueryNoLimit
        ) { [weak self] query, samples, deletedObjects, anchor, error in
            self?.processHeartRateSamples(samples)
        }
        
        query.updateHandler = { [weak self] query, samples, deleted, anchor, error in
            self?.processHeartRateSamples(samples)
        }
        
        healthStore.execute(query)
    }
    
    private func processHeartRateSamples(_ samples: [HKSample]?) {
        guard let samples = samples as? [HKQuantitySample] else { return }
        if let lastSample = samples.last {
            DispatchQueue.main.async {
                self.heartRate = lastSample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
            }
        }
    }
    
    func startUpdates() {
        motionManager.startDeviceMotionUpdates(
            to: .main
        ) { [weak self] motion, error in
            guard let motion = motion else { return }
            self?.rotationRate = motion.rotationRate
            self?.userAcceleration = motion.userAcceleration
        }
        
        setupTimer(interval: samplingRate.saveInterval)
        startHeartRateQuery()
    }
    
    func stopUpdates() {
        motionManager.stopDeviceMotionUpdates()
        workoutSession?.end()
        timer?.invalidate()
        timer = nil
    }
    
    private func setupTimer(interval: TimeInterval) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.saveReading()
        }
    }
    
    private func saveReading() {
        guard let currentSession = currentSession,
              let modelContext = modelContext else { return }
        
        let reading = SensorReading(
            timestamp: Date(),
            heartRate: heartRate,
            rotationX: rotationRate.x,
            rotationY: rotationRate.y,
            rotationZ: rotationRate.z,
            accelerationX: userAcceleration.x,
            accelerationY: userAcceleration.y,
            accelerationZ: userAcceleration.z,
            session: currentSession
        )
        
        if currentSession.readings == nil {
            currentSession.readings = []
        }
        currentSession.readings?.append(reading)
        
        modelContext.insert(reading)
        try? modelContext.save()
    }
    
    func startNewSession(samplingRate: SamplingRate, modelContext: ModelContext) {
        self.samplingRate = samplingRate
        self.modelContext = modelContext
        
        currentSession = Session(isFavorite: false)
        modelContext.insert(currentSession!)
        
        // Update intervals based on sampling rate
        setupMotionUpdates()
        setupTimer(interval: samplingRate.saveInterval)
    }
    
    func stopCurrentSession() {
        currentSession?.endTime = Date()
        if let modelContext = modelContext {
            try? modelContext.save()
        }
        currentSession = nil
        modelContext = nil
    }
    
    deinit {
        stopUpdates()
        timer?.invalidate()
    }
} 