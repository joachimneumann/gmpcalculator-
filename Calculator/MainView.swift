//
//  MainView.swift
//  Calculator
//
//  Created by Joachim Neumann on 24/09/2021.
//

import SwiftUI

struct MainView: View {
    @ObservedObject var brain: Brain
    var t: TE
    
    struct Keys: View {
        let brain: Brain
        var t: TE
        var body: some View {
            HStack(spacing: 0.0) {
                ScientificKeys(brain: brain, t: t)
                    .padding(.trailing, t.spaceBetweenkeys)
                NumberKeys(brain: brain, t: t)
                Spacer(minLength: 0.0)
            }
            .frame(height: t.allkeysHeight)
            .transition(.move(edge: .bottom))
        }
    }
    
    struct Rad: View {
        let keySize: CGSize
        let textColor: Color
        var body: some View {
            VStack(spacing: 0.0) {
                Spacer(minLength: 0.0)
                Text("Rad")
                    .font(Font.system(size: keySize.height*0.27).monospacedDigit())
                    .foregroundColor(Color.yellow)
                    .padding(.leading, keySize.height*0.27)
                    .padding(.bottom, keySize.height*0.1)
            }
        }
    }
    
    var body: some View {
        ZStack {
            if true { //}!t.isPad {
                HStack(spacing: 0.0) {
                    Spacer(minLength: 0.0)
                    Zoom(scrollTarget: $brain.scrollViewTarget,
                         iconName: brain.zoomed ? brain.precisionIconName : "plus.circle.fill",
                         iconSize: t.colorOpProperties.size.height * 0.7,
                         textColor: t.digits_1_9.textColor,
                         zoomed: $brain.zoomed,
                         showCalculating: brain.showCalculating)
                        .frame(width: t.colorOpProperties.size.width, height: t.colorOpProperties.size.height, alignment: .center)
                        .padding(.bottom, t.allkeysHeight + t.spaceBetweenkeys)
                }
            }
            if true {
                HStack(spacing: 0.0) {
                    Spacer(minLength: 0.0)
                    Precision(brain: brain, textColor: t.digits_1_9.textColor,
                              iconSize: t.colorOpProperties.size.height * 0.7)
                        .frame(width: t.colorOpProperties.size.width, height: t.colorOpProperties.size.height, alignment: .center)
                        .padding(.bottom, t.allkeysHeight + t.spaceBetweenkeys - t.colorOpProperties.size.height * 2.5)
                }
            }
            
            VStack(spacing: 0.0) {
                HStack(spacing: 0.0) {
                    if brain.rad && !brain.zoomed {
                        Rad(keySize: t.digits_1_9.size, textColor: t.digits_1_9.textColor)
                    }
                    Spacer(minLength: 0.0)
                    VStack(spacing: 0.0) {
                        if t.isPad {
                        }
                        Spacer(minLength: 0.0)
                    }
                }
                if !brain.zoomed {
                    Keys(brain: brain, t: t)
                        .background(TE.appBackgroundColor)
                }
            }
        }
        .background(
            VStack {
                Spacer(minLength: brain.zoomed ? t.displayTopPaddingZoomed : t.displayTopPaddingNotZoomed)
                Display(brain: brain, t: t)
                    .padding(.trailing, t.digits_1_9.size.width * 1.0)
                    .animation(nil, value: UUID())
            }
        )
    }
}

