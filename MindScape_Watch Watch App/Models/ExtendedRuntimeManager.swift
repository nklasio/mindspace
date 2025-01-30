import WatchKit

class ExtendedRuntimeManager: NSObject, ObservableObject {
    static let shared = ExtendedRuntimeManager()
    private var session: WKExtendedRuntimeSession?
    private var pendingStart = false
    
    func startSession() {
        guard session == nil || session?.state != .running else {
            print("Extended runtime session already running")
            return
        }
        
        if WKApplication.shared().applicationState == .active {
            print("Starting extended runtime session immediately")
            startSessionInternal()
        } else {
            print("Scheduling extended runtime session for when app becomes active")
            pendingStart = true
        }
    }
    
    private func startSessionInternal() {
        session = WKExtendedRuntimeSession()
        session?.delegate = self
        session?.start()
        print("Started extended runtime session")
    }
    
    func invalidateSession() {
        pendingStart = false
        session?.invalidate()
        session = nil
        print("Invalidated extended runtime session")
    }
    
    func handleAppBecameActive() {
        if pendingStart {
            print("App became active, starting pending session")
            startSessionInternal()
            pendingStart = false
        }
    }
}

extension ExtendedRuntimeManager: WKExtendedRuntimeSessionDelegate {
    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession, didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason, error: Error?) {
        DispatchQueue.main.async {
            self.session = nil
            print("Extended runtime session invalidated: \(reason)")
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("Extended runtime session started")
    }
    
    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("Extended runtime session will expire")
    }
} 