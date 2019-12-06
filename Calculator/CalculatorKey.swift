//
//  CalculatorKey.swift
//  Calculator
//
//  Created by Joachim Neumann on 04.12.19.
//  Copyright © 2019 mindo software S.L. All rights reserved.
//

import Foundation
import UIKit



@IBDesignable class CalculatorKey: UIView {
    
    @IBInspectable var buttonTitle: String = ""
    @IBInspectable var wideButton: Bool = false
    
    // Set up non-zero-sized storage. We don't intend to mutate this variable,
    // but it needs to be `var` so we can pass its address in as UnsafeMutablePointer.
    private static var myContext = 0
    // NOTE: `static` is not necessary if you want it to be a global variable

    let operationColor        = UIColor(red:  90/255.0, green: 200/255.0, blue: 250/255.0, alpha: 1)
    let operationColorPressed = UIColor(red: 175/255.0, green: 233/255.0, blue: 245/255.0, alpha: 1)
    let clearColor            = UIColor(red: 164/255.0, green: 164/255.0, blue: 164/255.0, alpha: 1)
    let clearColorPressed     = UIColor(red: 217/255.0, green: 217/255.0, blue: 217/255.0, alpha: 1)
    let digitsColor           = UIColor(red:  52/255.0, green:  52/255.0, blue:  52/255.0, alpha: 1)
    let digitsColorPressed    = UIColor(red: 115/255.0, green: 115/255.0, blue: 115/255.0, alpha: 1)
    
    enum keyType {
        case undefined
        case C
        case signChange
        case inverse
        case operation
        case digit
        case zero
        case dot
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        sharedInit()
        addObserver(self, forKeyPath: "bounds", options: [], context: &CalculatorKey.myContext)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if context == &CalculatorKey.myContext {
            sharedInit()
        }
        else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    var type: keyType {
        switch buttonTitle {
        case "+", "−", "×", "÷", "=":
            return .operation
        case "1", "2", "3", "4", "5", "6", "7", "8", "9":
            return .digit
        case "0":
            return .zero
        case ",":
            return .dot
        case "C":
            return .C
        case "±":
            return .signChange
        case "1/x":
            return .inverse
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
    
    var button: UIButton = UIButton()
    
    override func prepareForInterfaceBuilder() {
        sharedInit()
    }
    
    func sharedInit() {
        var buttonFrame = self.frame
        if isSquare {
            if wideButton {
                if (frame.size.width > 1.8 * frame.size.height) {
                    // wide horizontal rectangle
                    buttonFrame.size.height = frame.size.height
                    buttonFrame.size.width  = 1.8 * frame.size.height
                    buttonFrame.origin.y = 0
                    buttonFrame.origin.x = (frame.size.width - 1.8 * frame.size.height) / 2
                } else if (frame.size.width > frame.size.height) {
                    // small horizontal rectangle
                    buttonFrame.size.height = frame.size.height
                    buttonFrame.size.width  = frame.size.height
                    buttonFrame.origin.y = 0
                    buttonFrame.origin.x = (frame.size.width - frame.size.height) / 2
                } else {
                    // vertical rectangle
                    buttonFrame.size.height = frame.size.width
                    buttonFrame.size.width  = frame.size.width
                    buttonFrame.origin.x = 0
                    buttonFrame.origin.y = (frame.size.height - frame.size.width) / 2
                }
            } else {
                if (frame.size.width > frame.size.height) {
                    // horizontal rectangle
                    buttonFrame.size.height = frame.size.height
                    buttonFrame.size.width  = frame.size.height
                    buttonFrame.origin.y = 0
                    buttonFrame.origin.x = (frame.size.width - frame.size.height) / 2
                } else {
                    // vertical rectangle
                    buttonFrame.size.height = frame.size.width
                    buttonFrame.size.width  = frame.size.width
                    buttonFrame.origin.x = 0
                    buttonFrame.origin.y = (frame.size.height - frame.size.width) / 2
                }
            }
        } else {
            // not square
            buttonFrame.origin.x = 0
            buttonFrame.origin.y = 0
            var spacing:CGFloat = 0
            if let sv = superview as? UIStackView {
                spacing = sv.spacing
            }
            let newHeight = (buttonFrame.size.width - spacing) / 2
            let newY = (buttonFrame.size.height - newHeight) / 2
            buttonFrame.size.height = newHeight
            buttonFrame.origin.y = newY
            
        }
        button.frame = buttonFrame
        button.setTitle(buttonTitle, for: .normal)
        var fontSize = buttonFrame.size.height * 0.48
        if type == .operation {
            fontSize *= 1.2
        }
        button.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
        backgroundColor = .yellow
//        backgroundColor = .clear
        addSubview(button)
        
        button.removeTarget(nil, action: nil, for: .allEvents)
        button.addTarget(self, action:#selector(touchDown), for: UIControl.Event.touchDown)
        button.addTarget(self, action:#selector(touchUp), for: UIControl.Event.touchUpInside)
        setColorUp()
        refreshCorners()
        switch type {
        case .undefined:
            button.setTitleColor(.white, for: .normal)
        case .digit:
            button.setTitleColor(.white, for: .normal)
        case .zero:
            button.setTitleColor(.white, for: .normal)
            button.contentHorizontalAlignment = .left;
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: fontSize * 0.7, bottom: 0, right: 0)
        case .dot:
            button.setTitleColor(.white, for: .normal)
        case .operation:
            button.setTitleColor(.white, for: .normal)
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: fontSize/5, right: 0)
        case .C, .signChange, .inverse:
            button.setTitleColor(.black, for: .normal)
        }

        if buttonTitle == "±" {
            button.setImage(UIImage(named: buttonTitle), for: UIControl.State())
            button.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: fontSize/1.7, bottom: 0, right: fontSize/1.7)
            button.setTitle("", for: .normal)
        }
        if buttonTitle == "1/x" {
            button.setImage(UIImage(named: "1_x"), for: UIControl.State())
            button.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: fontSize/3, bottom: 0, right: fontSize/3)
            button.setTitle("", for: .normal)
        }

    }
    
    func refreshCorners() {
        let radius: CGFloat = min(button.frame.size.height, button.frame.size.width) / 2
        button.layer.cornerRadius = radius
    }

    func setColorUp() {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: UIView.AnimationOptions.allowUserInteraction, animations: {
            switch self.type {
                case .undefined:
                    self.button.backgroundColor = UIColor.systemPink
                case .digit:
                    self.button.backgroundColor = self.digitsColor
                case .zero:
                    self.button.backgroundColor = self.digitsColor
                case .dot:
                    self.button.backgroundColor = self.digitsColor
                case .operation:
                    self.button.backgroundColor = self.operationColor
                case .C, .signChange, .inverse:
                    self.button.backgroundColor = self.clearColor
                }
            }, completion: nil
        )
    }

    func setColorDown() {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: UIView.AnimationOptions.allowUserInteraction, animations: {
            switch self.type {
                case .undefined:
                    self.button.backgroundColor = UIColor.systemPink
                case .digit:
                    self.button.backgroundColor = self.digitsColorPressed
                case .zero:
                    self.button.backgroundColor = self.digitsColorPressed
                case .dot:
                    self.button.backgroundColor = self.digitsColorPressed
                case .operation:
                    self.button.backgroundColor = self.operationColorPressed
                case .C, .signChange, .inverse:
                    self.button.backgroundColor = self.clearColorPressed
                }
            }, completion: nil
        )
    }

    @objc func touchDown() {
        setColorDown()
    }

    @objc func touchUp() {
        setColorUp()
        switch type {
        case .digit, .zero:
            Brain.shared.digit(buttonTitle)
        case .dot:
            Brain.shared.digit(".") // comma does not work
        case .operation, .signChange:
            Brain.shared.operation(buttonTitle)
        case .inverse:
            Brain.shared.operation("1\\x")
        case .C:
            Brain.shared.reset()
        default:
            break
//        case .undefined:
//        case .digit:
//        case .zero:
//        case .dot:
//        case .operation:
//        case .clear:
        }
    }
    
}
