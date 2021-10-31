//
//  Precision.swift
//  Calculator
//
//  Created by Joachim Neumann on 10/23/21.
//

import SwiftUI

struct Precision: View {
    @ObservedObject var brain: Brain
    let textColor: Color
    let iconSize: CGFloat
    var body: some View {
        Image(systemName: "00.circle")
            .resizable()
            .foregroundColor(textColor)
            .onTapGesture {
                withAnimation(.easeIn) {
                    if brain.precision == TE.lowPrecision {
                        brain.messageToUser = TE.mediumPrecisionString
                        brain.precision = TE.mediumPrecision
                    } else if brain.precision == TE.mediumPrecision {
                        brain.messageToUser = TE.highPrecisionString
                        brain.precision = TE.highPrecision
                    } else {
                        // high precision
                        brain.messageToUser = TE.lowPrecisionString
                        brain.precision = TE.lowPrecision
                    }
                }
            }
            .frame(width: iconSize, height: iconSize)
    }
}
