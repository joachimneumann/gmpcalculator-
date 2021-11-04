//
//  TE.swift
//  Calculator
//
//  Created by Joachim Neumann on 23/09/2021.
//

import SwiftUI

struct KeyProperties {
    let size: CGSize
    let font: Font
    let textColor: Color
    let downTextColor: Color
    let bgColor: Color
    let downBgColor: Color
    let downAnimationTime: Double
    let upAnimationTime: Double
}

class TE {
    static let iPhoneScientificFontSizeReduction: CGFloat = 0.85//1.0
    static let digitsInAllDigitsDisplay: Int = 200
    static let numberPadFration: CGFloat = 0.4
    
    static let lowPrecision          = 100
    static let lowPrecisionString    = "one hundred digits"
    static let mediumPrecision       = 10000
    static let mediumPrecisionString = "ten thousand digits"
    static let highPrecision         = 1000000
    static let highPrecisionString   = "one million digits"


#if targetEnvironment(macCatalyst)
    /// The MacOS Calculator is a bit transparent.
    /// The colors specified here are the button colors
    /// when the MacOS Calcuator is on a black background.
    /// To make this app easily  distinguashable from the
    /// Apple MacOS Calculator, the 5 rightmost buttons
    /// have a blue tint instead of Apple's orange.
    static let appBackgroundColor = Color(
        red:    46.0/255.0,
        green:  39.0/255.0,
        blue:   38.0/255.0)

    let digits_1_9 = KeyProperties(
        size: CGSize(width: TE.kw,  height: TE.kh),
        font: Font.system(size: TE.kh * 0.45).monospacedDigit(),
        textColor: Color(
            red:   231.0/255.0,
            green: 231.0/255.0,
            blue:  231.0/255.0),
        downTextColor: Color(
            red:   231.0/255.0,
            green: 231.0/255.0,
            blue:  231.0/255.0),
        bgColor: Color(
            red:   98.0/255.0,
            green: 94.0/255.0,
            blue:  92.0/255.0),
        downBgColor: Color(
            red:   160.0/255.0,
            green: 159.0/255.0,
            blue:  158.0/255.0),
        downAnimationTime: 0.1,
        upAnimationTime: 0.5)
    
    let digits_0 = KeyProperties(
        size: CGSize(width: 2.0 * TE.kw + TE.sp,  height: TE.kh),
        font: Font.system(size: TE.kh * 0.45).monospacedDigit(),
        textColor: Color(
            red:   231.0/255.0,
            green: 231.0/255.0,
            blue:  231.0/255.0),
        downTextColor: Color(
            red:   231.0/255.0,
            green: 231.0/255.0,
            blue:  231.0/255.0),
        bgColor: Color(
            red:   98.0/255.0,
            green: 94.0/255.0,
            blue:  92.0/255.0),
        downBgColor: Color(
            red:   160.0/255.0,
            green: 159.0/255.0,
            blue:  158.0/255.0),
        downAnimationTime: 0.1,
        upAnimationTime: 0.5)


    let colorOpProperties = KeyProperties(
        size: CGSize(width: TE.wkw,  height: TE.kh),
        font: Font.system(size: TE.kh * 0.36, weight: .bold).monospacedDigit(),
        textColor: Color(
            red:   236.0/255.0,
            green: 235.0/255.0,
            blue:  235.0/255.0),
        downTextColor: Color(
            red:   236.0/255.0,
            green: 235.0/255.0,
            blue:  235.0/255.0),
        bgColor: Color(
            red:   105.0/255.0,
            green: 183.0/255.0,
            blue:  191.0/255.0),
        downBgColor: Color(
            red:   203.0/255.0,
            green: 230.0/255.0,
            blue:  232.0/255.0),
        downAnimationTime: 0.1,
        upAnimationTime: 0.3)

    let ac_plus_minus_percentProperties = KeyProperties(
        size: CGSize(width: TE.kw,  height: TE.kh),
        font: Font.system(size: TE.kh * 0.36).monospacedDigit(),
        textColor: Color(
            red:   236.0/255.0,
            green: 235.0/255.0,
            blue:  235.0/255.0),
        downTextColor: Color(
            red:   236.0/255.0,
            green: 235.0/255.0,
            blue:  235.0/255.0),
        bgColor: Color(
            red:    66.0/255.0,
            green:  62.0/255.0,
            blue:   59.0/255.0),
        downBgColor: Color(
            red:   124.0/255.0,
            green: 125.0/255.0,
            blue:  127.0/255.0),
        downAnimationTime: 0.1,
        upAnimationTime: 0.5)

    let scientificProperties = KeyProperties(
        size: CGSize(width: TE.kw,  height: TE.kh),
        font: Font.system(size: TE.kh * 0.38).monospacedDigit(),
        textColor: Color(
            red:   236.0/255.0,
            green: 235.0/255.0,
            blue:  235.0/255.0),
        downTextColor: Color(
            red:   236.0/255.0,
            green: 235.0/255.0,
            blue:  235.0/255.0),
        bgColor: Color(
            red:    66.0/255.0,
            green:  62.0/255.0,
            blue:   59.0/255.0),
        downBgColor: Color(
            red:   124.0/255.0,
            green: 125.0/255.0,
            blue:  127.0/255.0),
        downAnimationTime: 0.0,
        upAnimationTime: 0.0)

    /// I have selected "Optimize Interface for Mac" in target settings, general, which is 0.77 times smaller
    static private let kh: CGFloat  = 63.00 * 0.77 /// key height
    static private let kw: CGFloat  = 72.75 * 0.77 /// key width
    static private let wkw: CGFloat = 77.00 * 0.77 /// wider with for +-*/= keys
    static private let sp: CGFloat  = 1.0          /// space between keys

    static private let zoomIconSize: CGFloat = 30.0 * 0.77
    static let macWindowWidth: CGFloat = 9.0 * TE.kw + TE.wkw + 9.0 * TE.sp
    static let macWindowHeight: CGFloat = 419.5 * 0.77

    static private let numberPadWidth = 5.0 * TE.kw + 4.0 * TE.sp
    
    private static let staticDisplayFontSize: CGFloat = TE.numberPadWidth * 0.148
    let displayFontSize: CGFloat = TE.staticDisplayFontSize
    let scientificKeyFontSize = TE.kh * 0.36
    let digitsInSmallDisplay: Int = 16
    let isLandscape: Bool = true
    let spaceBetweenkeys: CGFloat = TE.sp
    let displayFont: Font = Font.system(size: TE.staticDisplayFontSize, weight: .thin).monospacedDigit()
    let widerKeySize: CGSize  = CGSize(width: TE.wkw, height: TE.kh)
    let scientificKeySize: CGSize   = CGSize(width: TE.kw,  height: TE.kh)
    let allkeysHeight: CGFloat = 5.0 * TE.kh + 4.0 * TE.sp
    let isPad: Bool = false
    let zeroLeadingPadding: CGFloat = TE.kw / 2 - TE.kh * 0.1
    let zoomTopPadding: CGFloat = 0.0
    let displayTopPaddingZoomed: CGFloat = 0.0
    let displayTopPaddingNotZoomed: CGFloat = 0.0
    let displayBottomPadding: CGFloat = 0.0
    let iconSize: CGFloat = TE.kh * 0.7
    let circularProgressViewScaleFactor: CGFloat = 0.77
    let isPortraitIPad = false

    struct ButtonShape: View {
        var body: some View {
            Rectangle()
        }
    }

#else
    ///
    /// iOS
    ///
    
    static let appBackgroundColor = Color(.black)


    let digits_1_9: KeyProperties
    let digits_0: KeyProperties
    let colorOpProperties: KeyProperties
    let ac_plus_minus_percentProperties: KeyProperties
    let scientificProperties: KeyProperties
    static let zoomIconSize: CGFloat = 30.0
    static let landscapeSpacingFration: CGFloat = 0.01

    var displayFontSize: CGFloat
    var displayFont: Font
    var spaceBetweenkeys: CGFloat
    var allkeysHeight: CGFloat
    var digitsInSmallDisplay: Int
    var isPad: Bool
    var zeroLeadingPadding: CGFloat
    var displayTopPaddingZoomed: CGFloat
    var displayTopPaddingNotZoomed: CGFloat
    var displayBottomPadding: CGFloat
    var zoomTopPadding: CGFloat
    var iconSize: CGFloat
    let circularProgressViewScaleFactor: CGFloat = 2.0
    var isPortraitIPad: Bool
    init(appFrame: CGSize, isPad: Bool) {
        self.isPad = isPad
        spaceBetweenkeys = appFrame.width * Self.landscapeSpacingFration
        let w = (appFrame.width - 9.0 * spaceBetweenkeys) * 0.1

        let squareKeysHeight = 5.0 * w + 4.0 * spaceBetweenkeys
        let factor:CGFloat = min(1.0, appFrame.height * 0.8 / squareKeysHeight)
        let keySize = CGSize(width: w, height: w * factor)
        let scientificKeyFontSize = keySize.height * 0.35
        let digitsKeyFontSize     = keySize.height * 0.5
        digitsInSmallDisplay = 16
        displayFontSize = keySize.height
        displayFont = Font.system(size: displayFontSize, weight: .thin).monospacedDigit()
        allkeysHeight = 5.0 * keySize.height + 4.0 * spaceBetweenkeys
        zeroLeadingPadding = keySize.width / 2 - digitsKeyFontSize*0.25
        iconSize = keySize.height * 0.7
        isPortraitIPad = false
        if isPad {
            if appFrame.width > appFrame.height {
                /// iPad landscape
                displayTopPaddingNotZoomed = appFrame.height - allkeysHeight - keySize.height - spaceBetweenkeys
                displayTopPaddingZoomed = displayTopPaddingNotZoomed
                zoomTopPadding = displayTopPaddingNotZoomed
                displayBottomPadding = 0.0
            } else {
                /// iPad portrait
                zoomTopPadding = 0.0
                displayTopPaddingNotZoomed = appFrame.height - allkeysHeight - keySize.height - spaceBetweenkeys
                displayTopPaddingZoomed = 0.0
                displayBottomPadding = allkeysHeight
                isPortraitIPad = true
            }
        } else {
            /// iPhone
            zoomTopPadding = 0.5 * (keySize.height + spaceBetweenkeys - iconSize)
            displayTopPaddingNotZoomed = appFrame.height - allkeysHeight - keySize.height - spaceBetweenkeys
            displayTopPaddingZoomed = displayTopPaddingNotZoomed
            displayBottomPadding = 0.0
        }

        digits_1_9 = KeyProperties(
            size: keySize,
            font: Font.system(size: digitsKeyFontSize).monospacedDigit(),
            textColor: Color(
                red:   231.0/255.0,
                green: 231.0/255.0,
                blue:  231.0/255.0),
            downTextColor: Color(
                red:   231.0/255.0,
                green: 231.0/255.0,
                blue:  231.0/255.0),
            bgColor: Color(
                red:   51.0/255.0,
                green: 51.0/255.0,
                blue:  51.0/255.0),
            downBgColor: Color(
                red:   160.0/255.0,
                green: 159.0/255.0,
                blue:  158.0/255.0),
            downAnimationTime: 0.1,
            upAnimationTime: 0.5)
        
        digits_0 = KeyProperties(
            size: CGSize(width: 2.0 * keySize.width + spaceBetweenkeys, height: keySize.height),
            font: Font.system(size: digitsKeyFontSize).monospacedDigit(),
            textColor: Color(
                red:   231.0/255.0,
                green: 231.0/255.0,
                blue:  231.0/255.0),
            downTextColor: Color(
                red:   231.0/255.0,
                green: 231.0/255.0,
                blue:  231.0/255.0),
            bgColor: Color(
                red:   51.0/255.0,
                green: 51.0/255.0,
                blue:  51.0/255.0),
            downBgColor: Color(
                red:   160.0/255.0,
                green: 159.0/255.0,
                blue:  158.0/255.0),
            downAnimationTime: 0.1,
            upAnimationTime: 0.5)


        colorOpProperties = KeyProperties(
            size: keySize,
            font: Font.system(size: scientificKeyFontSize, weight: .bold).monospacedDigit(),
            textColor: Color(
                red:   255.0/255.0,
                green: 255.0/255.0,
                blue:  255.0/255.0),
            downTextColor: Color(
                red:   236.0/255.0,
                green: 235.0/255.0,
                blue:  235.0/255.0),
            bgColor: Color(
                red:   105.0/255.0,
                green: 183.0/255.0,
                blue:  191.0/255.0),
            downBgColor: Color(
                red:   203.0/255.0,
                green: 230.0/255.0,
                blue:  232.0/255.0),
            downAnimationTime: 0.1,
            upAnimationTime: 0.3)

        ac_plus_minus_percentProperties = KeyProperties(
            size: keySize,
            font: Font.system(size: scientificKeyFontSize).monospacedDigit(),
            textColor: Color(
                red:     0.0/255.0,
                green:   0.0/255.0,
                blue:    0.0/255.0),
            downTextColor: Color(
                red:   236.0/255.0,
                green: 235.0/255.0,
                blue:  235.0/255.0),
            bgColor: Color(
                red:   165.0/255.0,
                green: 165.0/255.0,
                blue:  165.0/255.0),
            downBgColor: Color(
                red:   124.0/255.0,
                green: 125.0/255.0,
                blue:  127.0/255.0),
            downAnimationTime: 0.1,
            upAnimationTime: 0.5)

        scientificProperties = KeyProperties(
            size: keySize,
            font: Font.system(size: scientificKeyFontSize).monospacedDigit(),
            textColor: Color(
                red:   236.0/255.0,
                green: 235.0/255.0,
                blue:  235.0/255.0),
            downTextColor: Color(
                red:   236.0/255.0,
                green: 235.0/255.0,
                blue:  235.0/255.0),
            bgColor: Color(
                red:    33.0/255.0,
                green:  33.0/255.0,
                blue:   33.0/255.0),
            downBgColor: Color(
                red:   124.0/255.0,
                green: 125.0/255.0,
                blue:  127.0/255.0),
            downAnimationTime: 0.0,
            upAnimationTime: 0.0)
    }

    struct ButtonShape: View {
        var body: some View {
            Capsule()
        }
    }

#endif
        
}
