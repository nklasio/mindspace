import WatchConnectivity

class WatchConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = WatchConnectivityManager()
    private var session: WCSession = .default
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
        print("WatchConnectivity initialized")
    }
    
    func sendMessage(_ message: [String: Any]) {
        guard session.activationState == .activated else {
            print("WatchConnectivity: Session not activated")
            return
        }
        
        #if os(iOS)
        guard session.isWatchAppInstalled else {
            print("WatchConnectivity: Watch app not installed")
            return
        }
        
        // Use updateApplicationContext instead of sendMessage for background support
        do {
            try session.updateApplicationContext(message)
            print("WatchConnectivity: Context updated")
        } catch {
            print("WatchConnectivity: Failed to update context: \(error.localizedDescription)")
        }
        #endif
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("WatchConnectivity: Received application context: \(applicationContext)")
        #if os(watchOS)
        handleMessage(applicationContext)
        #endif
    }
    
    // WCSessionDelegate methods
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WatchConnectivity: Session activation failed: \(error.localizedDescription)")
        } else {
            print("WatchConnectivity: Session activated")
        }
    }
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("WatchConnectivity: Session became inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("WatchConnectivity: Session deactivated")
        // Activate the new session after having switched to a new watch.
        session.activate()
    }
    #endif
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        print("WatchConnectivity: Received message: \(message)")
        if let command = message["command"] as? String {
            switch command {
            case "startRecording":
                if let qualityRaw = message["quality"] as? String,
                   let quality = RecordingQuality(rawValue: qualityRaw) {
                    NotificationCenter.default.post(
                        name: .startSleepRecording,
                        object: nil,
                        userInfo: ["quality": quality]
                    )
                }
            case "stopRecording":
                NotificationCenter.default.post(name: .stopSleepRecording, object: nil)
            default:
                break
            }
        }
    }
    
    #if os(watchOS)
    func handleBackgroundTask() {
        let message = session.receivedApplicationContext
        print("WatchConnectivity: Handling background message: \(message)")
        handleMessage(message)
    }
    
    private func handleMessage(_ message: [String: Any]) {
        if let command = message["command"] as? String {
            switch command {
            case "startRecording":
                if let qualityRaw = message["quality"] as? String,
                   let quality = RecordingQuality(rawValue: qualityRaw) {
                    NotificationCenter.default.post(
                        name: .startSleepRecording,
                        object: nil,
                        userInfo: ["quality": quality]
                    )
                    NotificationManager.shared.sendRecordingStateNotification(isStarting: true)
                }
            case "stopRecording":
                NotificationCenter.default.post(name: .stopSleepRecording, object: nil)
                NotificationManager.shared.sendRecordingStateNotification(isStarting: false)
            default:
                break
            }
        }
    }
    #endif
} 