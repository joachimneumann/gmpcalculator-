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
    static var landscape = false
    
    let operationColor        = UIColor(red:  81/255.0, green: 181/255.0, blue: 235/255.0, alpha: 1)
    let operationColorPressed = UIColor(red: 209/255.0, green: 222/255.0, blue: 243/255.0, alpha: 1)
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
        case equal
        case extendedOperation
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
            sizeChanged()
        }
        else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    var type: keyType {
        switch buttonTitle {
        case "+", "−", "×", "÷":
            return .operation
        case "=":
            return .equal
        case "x^2", "x^3", "e^x", "10^x":
            return .extendedOperation
        case "√", "3√", "ln", "log10":
            return .extendedOperation
        case "x^y", "x↑↑y", "e", "π":
            return .extendedOperation
        case "x!", "sin", "cos", "tan":
            return .extendedOperation
        case "Z", "asin", "acos", "atan":
            return .extendedOperation
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
        if CalculatorKey.landscape { return false }
        switch type {
        case .zero:
            return false
        default:
            return true
        }
    }
    
    var pending: Bool {
        set {
            if newValue {
                setPendingStart()
            } else {
                setPendingEnd()
            }
        }
        get {
            return false
        }
    }

    var button: UIButton = UIButton()
    
    override func prepareForInterfaceBuilder() {
        sharedInit()
    }
    
    func sizeChanged() {
        var buttonFrame = self.frame
        buttonFrame.origin.x = 0
        buttonFrame.origin.y = 0
        if isSquare {
            if wideButton {
                buttonFrame.size.height = frame.size.height
                buttonFrame.size.width  = frame.size.width
                
                // not more than 2 times as wide as high
                if frame.size.width > 2 * frame.size.height {
                    buttonFrame.size.width  = frame.size.height * 2
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
        }

        var fontSize = buttonFrame.size.height * 0.45
        
        button.frame = buttonFrame

        switch type {
        case .zero:
            let leftInset = buttonFrame.size.width * 0.25 - fontSize * 0.35
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: 0)
        case .operation, .equal:
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: fontSize/5, right: 0)
        case .signChange:
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: fontSize/5, right: 0)
        default:
            break
        }

        switch type {
        case .operation, .signChange, .equal:
            fontSize = buttonFrame.size.height * 0.5
        default:
            fontSize = buttonFrame.size.height * 0.45
            break
        }
        
        button.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
        refreshCorners()
    }

    func sharedInit() {
        sizeChanged()
        button.setTitle(buttonTitle, for: .normal)
//        if buttonTitle == "log10" {
            button.titleLabel?.adjustsFontSizeToFitWidth = true
//        }
        //        backgroundColor = .yellow
        backgroundColor = .clear
        
        addSubview(button)
        
        button.addTarget(self, action:#selector(touchDown), for: UIControl.Event.touchDown)
        button.addTarget(self, action:#selector(touchUp), for: UIControl.Event.touchUpInside)
        setColorUp()
        setPendingEnd()
        switch type {
        case .undefined:
            button.setTitleColor(.white, for: .normal)
        case .digit, .extendedOperation:
            button.setTitleColor(.white, for: .normal)
        case .zero:
            button.setTitleColor(.white, for: .normal)
            button.contentHorizontalAlignment = .left;
        case .dot:
            button.setTitleColor(.white, for: .normal)
        case .operation, .equal, .C, .signChange, .inverse:
            button.setTitleColor(.white, for: .normal)
        }

        if let imagecandidate = UIImage(named: buttonTitle) {
        button.setImage(imagecandidate, for: UIControl.State())
        button.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
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
            case .digit, .extendedOperation:
                    self.button.backgroundColor = self.digitsColor
                case .zero:
                    self.button.backgroundColor = self.digitsColor
                case .dot:
                    self.button.backgroundColor = self.digitsColor
                case .operation, .equal, .C:
                    self.button.backgroundColor = self.operationColor
                case .signChange, .inverse:
                    self.button.backgroundColor = self.digitsColor
                }
            }, completion: nil
        )
    }

    func setColorDown() {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: UIView.AnimationOptions.allowUserInteraction, animations: {
            switch self.type {
            case .undefined:
                self.button.backgroundColor = UIColor.systemPink
            case .digit, .extendedOperation:
                self.button.backgroundColor = self.digitsColorPressed
            case .zero:
                self.button.backgroundColor = self.digitsColorPressed
            case .dot:
                self.button.backgroundColor = self.digitsColorPressed
            case .operation, .equal, .C:
                self.button.backgroundColor = self.operationColorPressed
            case .signChange, .inverse:
                self.button.backgroundColor = self.digitsColorPressed
            }
            }, completion: nil
        )
    }

    func setPendingStart() {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: UIView.AnimationOptions.allowUserInteraction, animations: {
            switch self.type {
                case .extendedOperation:
                    self.button.backgroundColor = UIColor.lightGray
                case .operation:
                    self.button.backgroundColor = UIColor.white
                    self.button.setTitleColor(self.operationColor, for: .normal)
            default:
                break
            }
        }, completion: nil)
    }
    
    func setPendingEnd() {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: UIView.AnimationOptions.allowUserInteraction, animations: {
            switch self.type {
            case .extendedOperation:
                self.button.backgroundColor = self.digitsColor
            case .operation:
                self.button.backgroundColor = self.operationColor
                self.button.setTitleColor(.white, for: .normal)
            default:
                break
            }
        }, completion: nil)
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
        case .operation, .equal, .signChange, .extendedOperation:
            Brain.shared.operation(buttonTitle)
        case .inverse:
            Brain.shared.operation("1\\x")
        case .C:
            Brain.shared.reset()
        default:
            break
        }
    }
    
}
