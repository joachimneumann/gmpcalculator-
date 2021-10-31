//
//  iOSSize.swift
//  Calculator
//
//  Created by Joachim Neumann on 02/10/2021.
//

#if targetEnvironment(macCatalyst)
// nothing to compile here...
#else

import SwiftUI

struct iOSSize: View {
    var brain: Brain
    var body: some View {
        GeometryReader { geo in
            let leadingPaddingNeeded: Bool  = (geo.safeAreaInsets.leading  == 0)
            let trailingPaddingNeeded: Bool = (geo.safeAreaInsets.trailing == 0)
            let bottomPaddingNeeded: Bool   = (geo.safeAreaInsets.bottom   == 0)
            
            let isPad: Bool = (UIDevice.current.userInterfaceIdiom == .pad)
            let horizontalFactor: CGFloat = CGFloat(1.0) -
            (leadingPaddingNeeded ? TE.landscapeSpacingFration : 0) -
            (trailingPaddingNeeded ? TE.landscapeSpacingFration : 0 )
            let verticalFactor: CGFloat = CGFloat(1.0) -
            (bottomPaddingNeeded ? TE.landscapeSpacingFration : 0.0)
            
            let appFrame = CGSize(
                width: geo.size.width * horizontalFactor,
                height: geo.size.height * verticalFactor)
            let t = TE(appFrame: appFrame, isPad: isPad)
            
            MainView(brain: brain, t: t)
                .padding(.leading,   leadingPaddingNeeded ? t.spaceBetweenkeys : 0)
                .padding(.trailing, trailingPaddingNeeded ? t.spaceBetweenkeys : 0)
                .padding(.bottom,   bottomPaddingNeeded   ? t.spaceBetweenkeys : 0)
        }
    }
}

#endif
