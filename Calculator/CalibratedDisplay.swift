//
//  CalibratedDisplay.swift
//  Calculator
//
//  Created by Joachim Neumann on 10/22/21.
//

import SwiftUI

struct NonScientificDisplay: View {
    @ObservedObject var brain: Brain
    let t: TE
    var body: some View {
        if let text = brain.nonScientific {
            let isLong = text.count >= TE.digitsInAllDigitsDisplay
            let textWithComment = (isLong && brain.precision == TE.mediumPrecision) ? text + "\n\ncopy to get \(TE.mediumPrecisionString)" : (isLong && brain.precision == TE.highPrecision) ? text + "\n\ncopy to get \(TE.highPrecisionString)" : text
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    Text(textWithComment)
                        .font(t.displayFont)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .foregroundColor(t.digits_1_9.textColor)
                        .font(t.displayFont)
                        .multilineTextAlignment(.trailing)
                        .id(1)
                }
                .disabled(!brain.zoomed)
                .onChange(of: brain.scrollViewTarget) { target in
                    if let target = target {
                        brain.scrollViewTarget = nil
                        withAnimation {
                            scrollViewProxy.scrollTo(target, anchor: .top)
                        }
                    }
                }
            }
        }
    }
}

struct ScientificDisplay: View {
    @ObservedObject var brain: Brain
    let t: TE
    var body: some View {
        if let scientific = brain.scientific {
            let isLong = scientific.mantissa.count >= TE.digitsInAllDigitsDisplay
            let mantissaWithComment = (isLong && brain.precision == TE.mediumPrecision) ? scientific.mantissa + "\n\ncopy to get \(TE.mediumPrecisionString)" : (isLong && brain.precision == TE.highPrecision) ? scientific.mantissa + "\n\ncopy to get \(TE.highPrecisionString)" : scientific.mantissa
            HStack(spacing: 0.0) {
                Spacer(minLength: 0.0)
                ScrollViewReader { scrollViewProxy in
                    ScrollView {
                        Text(mantissaWithComment)
                            .font(t.displayFont)
                            .foregroundColor(t.digits_1_9.textColor)
                            .multilineTextAlignment(.trailing)
                            .id(1)
                    }
                    .disabled(!brain.zoomed)
                    .onChange(of: brain.scrollViewTarget) { target in
                        if let target = target {
                            brain.scrollViewTarget = nil
                            withAnimation {
                                scrollViewProxy.scrollTo(target, anchor: .top)
                            }
                        }
                    }
                }
                VStack(spacing: 0.0) {
                    Text(" "+scientific.exponent)
                        .font(t.displayFont)
                        .foregroundColor(t.digits_1_9.textColor)
                        .lineLimit(1)
                    Spacer(minLength: 0.0)
                }
                .layoutPriority(1)
            }
        }
    }
}

struct CalibratedDisplay: View {
    @ObservedObject var brain: Brain
    let t: TE
    var body: some View {
        Group {
            if brain.nonScientific != nil || brain.messageToUser != nil {
                NonScientificDisplay(brain: brain, t: t)
            } else if brain.scientific != nil {
                ScientificDisplay(brain: brain, t: t)
            } else {
                EmptyView()
            }
        }
        .offset(x: 0, y: -0.03*t.displayFontSize)
        .contextMenu {
            Button(action: {
                UIPasteboard.general.string = brain.longDisplayString
            }) {
                Text("Copy to clipboard")
                Image(systemName: "doc.on.doc")
            }
            if UIPasteboard.general.hasStrings {
                Button(action: {
                    brain.asyncOperation("fromPasteboard")
                }) {
                    Text("Paste from clipboard")
                    Image(systemName: "doc.on.clipboard")
                }
            }
        }
    }
}
