import Foundation
import CoreHaptics
import AVFoundation

class HapticManager {
    static let shared = HapticManager()
    private var engine: CHHapticEngine?
    private var audioPlayer: AVAudioPlayer?
    
    init() {
        setupHaptics()
        setupAudio()
    }
    
    private func setupHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Failed to start haptic engine: \(error.localizedDescription)")
        }
    }
    
    private func setupAudio() {
        guard let soundURL = Bundle.main.url(forResource: "intervention", withExtension: "wav") else {
            print("Sound file not found")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.prepareToPlay()
        } catch {
            print("Failed to setup audio player: \(error.localizedDescription)")
        }
    }
    
    func preview(strength: Double) {
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(strength))
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(strength))
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play preview: \(error.localizedDescription)")
        }
    }
    
    func triggerIntervention(type: InterventionType, strength: Double) {
        switch type {
        case .haptic:
            triggerHaptic(strength: strength)
        case .sound:
            triggerSound(volume: strength)
        case .both:
            triggerHaptic(strength: strength)
            triggerSound(volume: strength)
        }
    }
    
    private func triggerHaptic(strength: Double) {
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(strength))
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(strength))
        
        var events: [CHHapticEvent] = []
        for i in 0..<3 {
            let event = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [intensity, sharpness],
                relativeTime: TimeInterval(i) * 0.2
            )
            events.append(event)
        }
        
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to trigger haptic: \(error.localizedDescription)")
        }
    }
    
    private func triggerSound(volume: Double) {
        audioPlayer?.volume = Float(volume)
        audioPlayer?.play()
    }
} 