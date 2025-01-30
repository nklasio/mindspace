import SwiftUI

struct RecordButton: View {
    let isRecording: Bool
    let action: () -> Void
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0)) {
                scale = 0.9
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0)) {
                    scale = 1.0
                }
            }
            action()
        }) {
            ZStack {
                Circle()
                    .fill(isRecording ? Color.red : Color.green)
                    .frame(width: 70, height: 70)
                    .blur(radius: 20)
                    .opacity(0.3)
                
                Circle()
                    .fill(isRecording ? Color.red : Color.green)
                    .frame(width: 60, height: 60)
                    .shadow(color: (isRecording ? Color.red : Color.green).opacity(0.5),
                           radius: 10, x: 0, y: 5)
                
                if isRecording {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 24, height: 24)
                } else {
                    Image(systemName: "moon.zzz.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 24))
                }
            }
            .scaleEffect(scale)
        }
        .buttonStyle(PlainButtonStyle())
    }
} 