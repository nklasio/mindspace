import SwiftUI
import Foundation

struct QualityPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selection: SamplingRate
    
    var body: some View {
        List {
            ForEach(SamplingRate.allCases, id: \.self) { rate in
                Button {
                    selection = rate
                    dismiss()
                } label: {
                    HStack {
                        qualityRow(for: rate)
                        if rate == selection {
                            Spacer()
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
            }
        }
        .navigationTitle("Recording Quality")
    }
} 