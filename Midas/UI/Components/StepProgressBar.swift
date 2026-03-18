//
//  StepProgressBar.swift
//  Midas
//

import SwiftUI

struct StepProgressBar: View {
    let currentStep: Int
    let totalSteps: Int
    let percentComplete: Int

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Step \(currentStep) of \(totalSteps)")
                    .font(.subheadline)
                    .fontDesign(.serif)
                    .italic()

                Spacer()

                Text("\(percentComplete)% COMPLETE")
                    .font(.caption2)
                    .tracking(2)
                    .foregroundStyle(.secondary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 4)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.brandDarkGreen)
                        .frame(
                            width: geometry.size.width * CGFloat(percentComplete) / 100,
                            height: 4
                        )
                        .animation(.easeInOut(duration: 0.3), value: percentComplete)
                }
            }
            .frame(height: 4)
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        StepProgressBar(currentStep: 1, totalSteps: 3, percentComplete: 33)
        StepProgressBar(currentStep: 2, totalSteps: 3, percentComplete: 66)
        StepProgressBar(currentStep: 3, totalSteps: 3, percentComplete: 100)
    }
    .padding()
}
