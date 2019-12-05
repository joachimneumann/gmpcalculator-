//
//  UIKey.swift
//  Calculator
//
//  Created by Joachim Neumann on 04.12.19.
//  Copyright © 2019 mindo software S.L. All rights reserved.
//

import Foundation
import UIKit



@IBDesignable class UIKey: UIButton {

    let operationColor        = UIColor(red:   0/255.0, green: 163/255.0, blue: 136/255.0, alpha: 1)
    let operationColorPressed = UIColor(red:  51/255.0, green: 213/255.0, blue: 187/255.0, alpha: 1)
    let clearColor            = UIColor(red: 164/255.0, green: 164/255.0, blue: 164/255.0, alpha: 1)
    let clearColorPressed     = UIColor(red: 217/255.0, green: 217/255.0, blue: 217/255.0, alpha: 1)
    let digitsColor           = UIColor(red:  52/255.0, green:  52/255.0, blue:  52/255.0, alpha: 1)
    let digitsColorPressed    = UIColor(red: 115/255.0, green: 115/255.0, blue: 115/255.0, alpha: 1)
    
    enum keyType {
        case undefined
        case clear
        case operation
        case digit
        case zero
        case dot
    }
    
    var type: keyType {
        switch titleLabel?.text {
        case "+", "−", "×", "÷":
            return .operation
        case "1", "2", "3", "4", "5", "6", "7", "8", "9":
            return .digit
        case "0":
            return .zero
        case ".":
            return .dot
        case "C", "±", "1/x":
            return .clear
        default:
            return .undefined
        }
    }

    var isSquare: Bool {
        switch type {
        case .zero:
            return false
        default:
            return true
        }
    }

    var heigtConstraint: NSLayoutConstraint?
    
    var square: Bool = true {
        didSet {
            heigtConstraint?.isActive = square
//            layoutIfNeeded()
            refreshCorners()
            layoutSubviews()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    override func prepareForInterfaceBuilder() {
        sharedInit()
    }
    
    func sharedInit() {
        heigtConstraint = self.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1.0/1.0)
        addTarget(self, action:#selector(setColorDown), for: UIControl.Event.touchDown)
        addTarget(self, action:#selector(setColorUp), for: UIControl.Event.touchUpInside)
        setColorUp()
        refreshCorners()
    }

    
    func refreshCorners() {
        let spacing: CGFloat = 28.0
        imageEdgeInsets = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: spacing)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: 0)

//        if isSquare {
//            NSLog("square %f %f", layoutMargins.left, layoutMargins.right)
//            layoutMargins.left = 20;
//            layoutMargins.right = 20;
//            NSLog("%f %f", layoutMargins.left, layoutMargins.right)
//        } else {
//            NSLog("NOT square %f %f", frame.size.height, frame.size.width)
//        }
        let radius: CGFloat = min(frame.size.height, frame.size.width) / 2
        layer.cornerRadius = radius
    }
    
    @objc func setColorDown() {
        switch type {
        case .undefined:
            backgroundColor = .systemPink
        case .digit:
            backgroundColor = digitsColorPressed
        case .zero:
            backgroundColor = digitsColorPressed
        case .dot:
            backgroundColor = digitsColorPressed
        case .operation:
            backgroundColor = operationColorPressed
        case .clear:
            backgroundColor = clearColorPressed
        }
    }

    @objc func setColorUp() {
        switch type {
        case .undefined:
            backgroundColor = .systemPink
        case .digit:
            backgroundColor = digitsColor
        case .zero:
            backgroundColor = digitsColor
        case .dot:
            backgroundColor = digitsColor
        case .operation:
            backgroundColor = operationColor
        case .clear:
            backgroundColor = clearColor
        }
    }



    
    
//    // Only override draw() if you perform custom drawing.
//    // An empty implementation adversely affects performance during animation.
//    override func draw(_ rect: CGRect) {
//        super.draw(rect)
//        let corner_radius : CGFloat =  4.0
//        self.clipsToBounds = true
//        self.layer.masksToBounds = true
//        self.layer.cornerRadius = corner_radius
//    }

}
