//
//  Display.swift
//  Calculator
//
//  Created by Joachim Neumann on 23/09/2021.
//

import SwiftUI

struct DisplayText: View {
    let text: String
    let font: Font
    var body: some View {
        Text(text)
            .font(font)
        
    }
}

struct Display: View {
    @ObservedObject var brain: Brain
    let t: TE
    @State var initialHeight: CGFloat? = nil
    
    var body: some View {
        if !brain.calibrated {
            VStack(alignment: .leading) {
                DisplayText(text: "0", font: t.displayFont)
                    .overlay(
                        GeometryReader { proxy in
                            Color.clear.onAppear {
                                initialHeight = proxy.size.height
                                DisplayData.digitsInOneLine = .max
                            }
                        }
                    )
                if let initialHeight = initialHeight {
                    FindIntegerDigitLimit(brain: brain, t: t, initialHeight: initialHeight)
                    FindFloatDigitLimit(brain: brain, t: t, initialHeight: initialHeight)
                    FindScientificDigitLimit(brain: brain, t: t, initialHeight: initialHeight)
                }
            }
        } else {
            CalibratedDisplay(brain: brain, t: t)
        }
    }
    
}


struct FindIntegerDigitLimit: View {
    var brain: Brain
    let t: TE
    let initialHeight: CGFloat
    var body: some View {
        ForEach((1..<40), id: \.self) { i in
            let s = String(repeating: "1", count: i)
            ScrollView {
                DisplayText(text: s, font: t.displayFont)
                    .overlay(
                        GeometryReader { proxy in
                            Color.clear
                                .onAppear {
                                    if proxy.size.height > initialHeight {
                                        if (i - 1) < DisplayData.digitsInOneLine {
                                            DisplayData.digitsInOneLine = (i - 1)
                                        }
//                                         print("i \(i) \(s.count) digitsInDisplayInteger \(DisplayData.digitsInOneLine) proxy.size.height \(proxy.size.height) \(initialHeight) \(s)")
                                    }
                                }
                        }
                    )
            }
        }
    }
}

struct FindFloatDigitLimit: View {
    var brain: Brain
    let t: TE
    let initialHeight: CGFloat
    var body: some View {
        ForEach((3..<40), id: \.self) { i in
            let s = "1,"+String(repeating: "1", count: (i - 1))
            ScrollView {
                DisplayText(text: s, font: t.displayFont)
                    .overlay(
                        GeometryReader { proxy in
                            Color.clear.onAppear {
                                if proxy.size.height > initialHeight {
                                    if (i - 1) < DisplayData.digitsInOneLine {
                                        DisplayData.digitsInOneLine = (i - 1)
                                    }
                                }
//                                 print("i \(i) digitsInDisplayFloat \(DisplayData.digitsInOneLine) \(s.count) proxy.size.height \(proxy.size.height) \(initialHeight) \(s)")
                            }
                        }
                    )
            }
        }
    }
}

struct FindScientificDigitLimit: View {
    var brain: Brain
    let t: TE
    let initialHeight: CGFloat
    var body: some View {
        ForEach((5..<40), id: \.self) { i in
            let s = "1,"+String(repeating: "1", count: (i - 1)-3)+" e77"
            ScrollView {
                DisplayText(text: s, font: t.displayFont)
                    .overlay(
                        GeometryReader { proxy in
                            Color.clear.onAppear {
                                if proxy.size.height > initialHeight {
                                    if (i - 1) < DisplayData.digitsInOneLine {
                                        DisplayData.digitsInOneLine = (i - 1)
                                    }
                                }
//                                 print("i \(i) digitsInDisplayScientific \(DisplayData.digitsInOneLine) \(s.count) proxy.size.height \(proxy.size.height) \(initialHeight) \(s)")
                                brain.calibrated = true
                            }
                        }
                    )
            }
        }
    }
}
