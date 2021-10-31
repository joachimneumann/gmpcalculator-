//
//  Symbols.swift
//  Calculator
//
//  Created by Joachim Neumann on 23/09/2021.
//

import SwiftUI

struct RootShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        var w: CGFloat = rect.size.width
        var h: CGFloat = rect.size.height
        let steepness: CGFloat = 2.8
        let f: CGFloat = 0.6
        let startX: CGFloat = (0.5 - 0.2 * TE.iPhoneScientificFontSizeReduction) * w
        let startY: CGFloat = (0.5 + 0.05 * TE.iPhoneScientificFontSizeReduction) * h
        w *= TE.iPhoneScientificFontSizeReduction
        h *= TE.iPhoneScientificFontSizeReduction
        let downX: CGFloat = startX + f * 0.08 * w
        let downY: CGFloat = startY + f * 0.08 * h * steepness
        let upX: CGFloat = downX + f * 0.2 * w
        let upY: CGFloat = downY - f * 0.2 * h * steepness
        let endX: CGFloat = upX + f * 0.35 * w
        let endY: CGFloat = upY
        
        path.move(to: CGPoint(x: startX, y: startY))
        path.addLine(to: CGPoint(x: downX, y: downY))
        path.addLine(to: CGPoint(x: upX,   y: upY))
        path.addLine(to: CGPoint(x: endX,  y: endY))
        return path
    }
}

struct SlashShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w: CGFloat = rect.size.width
        let h: CGFloat = rect.size.height
        var sw = 0.2 * w
        let steepness: CGFloat = 1.3
        let startX: CGFloat = 0.5 * w - 0.5 * sw * TE.iPhoneScientificFontSizeReduction
        let startY: CGFloat = 0.5 * h + 0.5 * sw * steepness * TE.iPhoneScientificFontSizeReduction
        sw *= TE.iPhoneScientificFontSizeReduction
        let upX: CGFloat = startX+sw
        let upY: CGFloat = startY-sw*steepness
        
        path.move(to: CGPoint(x: startX, y: startY))
        path.addLine(to: CGPoint(x: upX,   y: upY))
        return path
    }
}

struct Root: View {
    let root: String
    let strokeColor: Color
    var body: some View {
        ZStack {
            GeometryReader { geo in
                let w = geo.size.width * TE.iPhoneScientificFontSizeReduction
                let h = geo.size.height * TE.iPhoneScientificFontSizeReduction
                VStack(spacing:0.0) {
                    Spacer(minLength: 0.0)
                    HStack(spacing:0.0) {
                        ZStack {
                            Spacer(minLength: 0.0)
                            let fontSize1:CGFloat = 0.21276 * h
                            let fontSize2:CGFloat = 0.27659 * h
                            Text(root)
                                .font(.system(size: fontSize1, weight: .semibold))
                                .offset(x: -0.18 * w, y: -0.10 * h)
                            RootShape()
                                .stroke(strokeColor, style: StrokeStyle(lineWidth: 1.6 * h / 47.0, lineCap: CGLineCap.square, lineJoin: CGLineJoin.bevel))
                            Text("X")
                                .font(.system(size: fontSize2, weight: .semibold))
                                .offset(x: 0.08 * w, y: 0.05 * h)
                        }
                        Spacer(minLength: 0.0)
                    }
                    Spacer(minLength: 0.0)
                }
            }
        }
    }
    init(_ root: String, strokeColor: Color) {
        self.strokeColor = strokeColor
        self.root = root
    }
}

struct One_x: View {
    let strokeColor: Color
    var body: some View {
        ZStack {
            GeometryReader { geo in
                let w: CGFloat = geo.size.width*TE.iPhoneScientificFontSizeReduction
                let h: CGFloat = geo.size.height*TE.iPhoneScientificFontSizeReduction
                VStack(spacing: 0.0) {
                    Spacer(minLength: 0.0)
                    HStack(spacing: 0.0) {
                        Spacer(minLength: 0.0)
                        ZStack {
                            Text("1")
                                .font(.system(size: h * 0.25))
                                .offset(x: -0.10 * w, y: -0.10 * h)
                            SlashShape()
                                .stroke(strokeColor, style: StrokeStyle(lineWidth: 1.6 * w / 47.0, lineCap: CGLineCap.square, lineJoin: CGLineJoin.bevel))
                            Text("x")
                                .font(.system(size: h * 0.25))
                                .offset(x: 0.10 * w, y: 0.07 * h)
                        }
                        Spacer(minLength: 0.0)
                    }
                    Spacer(minLength: 0.0)
                }
            }
        }
    }
}


struct Logx: View {
    let base: String
    var body: some View {
        ZStack {
            GeometryReader { geo in
                let s = min(geo.size.width, geo.size.height)*TE.iPhoneScientificFontSizeReduction
                VStack(spacing:0.0) {
                    Spacer(minLength: 0.0)
                    HStack(spacing:0.0) {
                        Spacer(minLength: 0.0)
                        Text("log")
                            .font(.system(size: s * 0.4))
                        Text(base)
                            .font(.system(size: s * 0.22))
                            .offset(x: 0.0, y: 0.13 * s)
                        Spacer(minLength: 0.0)
                    }
                    Spacer(minLength: 0.0)
                }
            }
        }
    }
    init(_ base: String) { self.base = base }
}

struct Pow: View {
    let base: String
    let exponent: String
    var body: some View {
        ZStack {
            GeometryReader { geo in
                let s = min(geo.size.width, geo.size.height) * TE.iPhoneScientificFontSizeReduction
                VStack(spacing:0.0) {
                    Spacer(minLength: 0.0)
                    HStack(spacing: 0.0) {
                        Spacer(minLength: 0.0)
                        Text(base)
                            .font(.system(size: s * 0.4))
                        Text(exponent)
                            .font(.system(size: s * 0.22))
                            .offset(x: 0.0, y: -0.13 * s)
                        Spacer(minLength: 0.0)
                    }
                    Spacer(minLength: 0.0)
                }
            }
        }
    }
}

