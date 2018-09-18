//
//  CalculatorViewController.swift
//  Calculator
//
//  Created by Joachim Neumann on 09/05/2016.
//  Copyright © 2016 mindo software S.L. All rights reserved.
//

import UIKit

struct ColorPalette {
    static let BasicOperation = UIColor(red: 0.0/255.0, green: 163.0/255.0, blue: 136.0/255.0, alpha: 1.0)
    static let PressedBasicOperation = UIColor(red: 51/255.0, green: 213.0/255.0, blue: 187.0/255.0, alpha: 1.0)
    static let DarkOperation = UIColor(red: 192.0/255.0, green: 192.0/255.0, blue: 192.0/255.0, alpha: 1.0)
    static let Operation = UIColor(red: 164.0/255.0, green: 164.0/255.0, blue: 164.0/255.0, alpha: 1.0)
    static let Digits = UIColor(red: 52.0/255.0, green: 52.0/255.0, blue: 52.0/255.0, alpha: 1.0)
    static let DarkDigits = UIColor(red: 197.0/255.0, green: 164.0/255.0, blue: 140.0/255.0, alpha: 1.0)
}

let basicOperations = Set(["÷", "×", "−", "+", "="]) // for key colors
let pendingOperations = Set(["x^y", "x↑↑y"])
let cancelPendingOperations = Set(["C", "="])
let smallerScienceKeys = Set(["x^2", "x^3", "x^y", "e^x", "10^x", "√", "3√", "x↑↑y"])
let smallerBasicKeys = Set(["1/x", "±"])
let basicOperationKeys = Set(["1\\x", "±", "C"])

class CalculatorViewController: UIViewController {

    @IBOutlet weak var display: UITextView!
    @IBOutlet weak var precisionTextView: UITextView!
    @IBOutlet weak var programTextView: UITextView!
    @IBOutlet weak var displayLabel: UIView!

    @IBOutlet weak var scienceStack: UIStackView!
    @IBOutlet weak var science1Stack: UIStackView!
    @IBOutlet weak var science2Stack: UIStackView!
    @IBOutlet weak var science3Stack: UIStackView!
    @IBOutlet weak var science4Stack: UIStackView!
    @IBOutlet weak var precisionStack: UIStackView!
    @IBOutlet weak var keysStack: UIStackView!
    @IBOutlet weak var ACStack: UIStackView!
    @IBOutlet weak var _789Stack: UIStackView!
    @IBOutlet weak var _456Stack: UIStackView!
    @IBOutlet weak var _123Stack: UIStackView!
    @IBOutlet weak var _0Stack: UIStackView!
    
    @IBOutlet weak var scienceStackWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var keysStackWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var displayHeightConstraint: NSLayoutConstraint!
    
    fileprivate var userIsInTheMiddleOfTyping = false
    fileprivate let fmt = NumberFormatter()
    fileprivate var brain = CalculatorBrain()
    fileprivate var screenWidth:CGFloat = 300.0
    fileprivate var screenHeight:CGFloat = 300.0
    fileprivate var pendingButton: UIButton?
    var currentDeviceOrientation: UIDeviceOrientation = .unknown

    let defaultPrecision = 75
    
    fileprivate var savedProgram: CalculatorBrain.PropertyList?
    
   
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override var shouldAutorotate : Bool {
        return true
    }
    
   
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.all
    }
    
    // MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        display.indicatorStyle = UIScrollViewIndicatorStyle.white
        fmt.usesSignificantDigits = false
        fmt.maximumSignificantDigits = 10
        screenWidth = view.frame.size.width
        screenHeight = view.frame.size.height
        if (screenWidth > screenHeight) {
            let temp:CGFloat = screenWidth
            screenWidth = screenHeight
            screenHeight = temp
        }
        scienceStackWidthConstraint.constant = screenHeight*0.6 - 0.5
        
        for stack in keysStack.subviews {
            for key in stack.subviews {
                if let b = key as? UIButton {
                    if let titleLabel = b.titleLabel {
                        if let titleText = titleLabel.text {
                            if let image = UIImage(named: titleText) {
                                b.imageView?.contentMode = UIViewContentMode.scaleAspectFit
                                b.setImage(image, for: UIControlState())
                            }
                        }
                    }
                }
            }
            for stack in scienceStack.subviews {
                for key in stack.subviews {
                    if let b = key as? UIButton {
                        if let titleLabel = b.titleLabel {
                            if let titleText = titleLabel.text {
                                if let image = UIImage(named: titleText) {
                                    b.imageView?.contentMode = UIViewContentMode.scaleAspectFit
                                    b.setImage(image, for: UIControlState())
                                }
                            }
                        }
                    }
                }
            }
        }
        precisionTextView.textContainerInset = UIEdgeInsets.zero;
        precisionTextView.textContainer.lineFragmentPadding = 0;
        programTextView.textContainerInset = UIEdgeInsets.zero;
        programTextView.textContainer.lineFragmentPadding = 0;

    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layout()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        precisionTextView.text = "\(defaultPrecision) digits"
        
        programTextView.text = ""
        
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(CalculatorViewController.deviceDidRotate(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        // Initial device orientation
        switch UIDevice.current.orientation {
        case .landscapeRight:
            self.currentDeviceOrientation = .landscapeRight
        case .landscapeLeft:
            self.currentDeviceOrientation = .landscapeLeft
        default:
            self.currentDeviceOrientation = .portrait
        }
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        switch UIDevice.current.orientation {
        case .landscapeRight, .landscapeLeft:
            setPrecisionKeysBackgroundColor()
        case .portrait, .portraitUpsideDown:
            if brain.digits != defaultPrecision {
                brain.digits = defaultPrecision
                precisionTextView.text = "\(defaultPrecision) digits"
                updateDisplay()
            }
        default: ()
        }
    }

    @objc func deviceDidRotate(_ notification: Notification) {
        switch UIDevice.current.orientation {
        case .landscapeRight:
            self.currentDeviceOrientation = .landscapeRight
        case .landscapeLeft:
            self.currentDeviceOrientation = .landscapeLeft
        case .portrait:
            self.currentDeviceOrientation = .portrait
        case .portraitUpsideDown:
            self.currentDeviceOrientation = .portraitUpsideDown
        default: ()
        }
        layout()
    }
    

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
        if UIDevice.current.isGeneratingDeviceOrientationNotifications {
            UIDevice.current.endGeneratingDeviceOrientationNotifications()
        }
    }
    
    func updateDisplay() {
        display!.text = brain.result.toString()
        programTextView.text = brain.programDescription
    }
    
    
    override var prefersStatusBarHidden : Bool {
        return true;
    }
    
    func layout() {
        let sizeX = keysStack.frame.size.width / 4
        let sizeY = keysStack.frame.size.height / 5
        let size = min(sizeX, sizeY) * 0.89
        let deltaX = size * 0.0115
        let deltaY = size * 0.0115
        let radius = size / 2
        for stack in keysStack.subviews {
            for key in stack.subviews {
                if let b = key as? UIButton {
                    b.frame.size.width = size
                    b.frame.origin.x += deltaX
                    b.frame.size.height = size
                    b.frame.origin.y += deltaY
                    b.layer.cornerRadius = radius
                }
            }
            for key in stack.subviews {
                if let b = key as? UIButton {
                    if b.tag == 2 { // 0
                        b.frame.size.width = size + keysStack.frame.size.width / 4
                    }
                }
            }
        }
        for stack in scienceStack.subviews {
            for key in stack.subviews {
                if let b = key as? UIButton {
                    b.frame.size = CGSize(width: sizeY, height: size)
                    b.layer.cornerRadius = radius
                }
            }
        }
        
        
        switch self.currentDeviceOrientation {
        case .landscapeLeft, .landscapeRight:
            scienceStack.isHidden = false
            keysStackWidthConstraint.constant = screenHeight*0.4
            if brain.digits < 50 {
                displayHeightConstraint.constant =  screenWidth * 0.2
            } else {
                displayHeightConstraint.constant =  screenWidth * 0.4
            }
        case .portrait, .portraitUpsideDown:
            scienceStack.isHidden = true
            keysStackWidthConstraint.constant = screenWidth
            if brain.digits < 50 {
                displayHeightConstraint.constant =  screenHeight * 0.2
            } else {
                displayHeightConstraint.constant =  screenHeight * 0.3
            }
        default:
            // do nothing
            return
        }
        view.layoutIfNeeded()
        keyFontSize()
    }
    
    func keyFontSize() {
        let sizeX = keysStack.frame.size.width / 4
        let sizeY = keysStack.frame.size.height / 5
        let size = min(sizeX, sizeY) * 0.89
        var buttonFont: UIFont
        var largerButtonFont: UIFont
        var displayFont: UIFont
        var fontSize: CGFloat
        var inset: CGFloat
        switch self.currentDeviceOrientation {
        case .landscapeLeft, .landscapeRight:
            fontSize = round(keysStack.bounds.size.height * 0.07)
            inset = fontSize / 10
        case .portrait, .portraitUpsideDown:
            fontSize = round(keysStack.bounds.size.height * 0.07)
            inset = fontSize / 3
        default:
            // do nothing
            return
        }
        let displayFontSize = min(fontSize, 30)
        buttonFont = UIFont.systemFont(ofSize: fontSize)
        largerButtonFont = UIFont.systemFont(ofSize: fontSize*1.2)
        displayFont = UIFont.systemFont(ofSize: displayFontSize)
        for stack in scienceStack.subviews {
            for key in stack.subviews {
                if let b = key as? UIButton {
                    b.titleLabel!.font = buttonFont
                    b.titleLabel!.adjustsFontSizeToFitWidth = true
                    if let titleLabel = b.titleLabel {
                        titleLabel.font = buttonFont
                        if let titleText = titleLabel.text {
                            if smallerScienceKeys.contains(titleText) {
                                b.imageEdgeInsets = UIEdgeInsetsMake(inset, inset, inset, inset);
                            }
                        }
                    }
                }
            }
        }
        for stack in keysStack.subviews {
            for key in stack.subviews {
                if let b = key as? UIButton {
                    if let titleLabel = b.titleLabel {
                        // tag 1: digits 1 to 9
                        // tag 2: 0
                        // tag 3: / x - + =
                        // tag 0: all other
                        if b.tag == 1 {
                            b.setTitleColor(UIColor.white, for: UIControlState())
                            titleLabel.font = buttonFont
                            b.backgroundColor = ColorPalette.Digits
                        } else if b.tag == 2 {
                            b.setTitleColor(UIColor.white, for: UIControlState())
                            titleLabel.font = buttonFont
                            b.backgroundColor = ColorPalette.Digits
                            b.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: size*0.38, bottom: 0, right: -size*0.38)
                        } else if b.tag == 3 {
                            b.setTitleColor(UIColor.white, for: UIControlState())
                            titleLabel.font = largerButtonFont
                            b.backgroundColor = ColorPalette.BasicOperation
                            b.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: fontSize*0.1, right: 0)
                        } else {
                            b.setTitleColor(UIColor.black, for: UIControlState())
                            titleLabel.font = buttonFont
                        }
                        if let titleText = titleLabel.text {
                            if smallerBasicKeys.contains(titleText) {
                                b.imageEdgeInsets = UIEdgeInsetsMake(inset, inset, inset, inset);
                            }
                            if basicOperationKeys.contains(titleText) {
                                b.backgroundColor = ColorPalette.Operation
                            }
                        }
                    }
                }
            }
            display.font = displayFont
        }
    }

    
    
    @IBAction func basicOperationTouchDown(_ sender: UIButton) {
        sender.backgroundColor = ColorPalette.PressedBasicOperation
    }
    @IBAction func functionTouchDown(_ sender: UIButton) {
        sender.backgroundColor = ColorPalette.DarkOperation
    }
    @IBAction func digitTouchDown(_ sender: UIButton) {
        sender.backgroundColor = ColorPalette.DarkDigits
    }
    
    func setPrecisionKeysBackgroundColor() {
        for subview in precisionStack.subviews {
            if let b = subview as? UIButton {
                if b.titleLabel!.text == String(brain.digits) {
                    b.backgroundColor = ColorPalette.BasicOperation
                } else {
                    b.backgroundColor = ColorPalette.Operation
                }
            }
        }
    }
  
    @IBAction fileprivate func touchDigit(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
            sender.backgroundColor = ColorPalette.Digits
            }, completion: nil)

        var digit = sender.currentTitle!
        let currentText = display.text!
        
        // zeros at the beginning (display is "0") shall be ignored
        if !(digit == "0" && currentText == "0") {
            if userIsInTheMiddleOfTyping {
                digit = (digit == "." && currentText.range(of: ".") != nil) ? "" : digit
                display.text = currentText + digit
                brain.setDigit(display.text)
            } else {
                digit = (digit == ".") ? "0." : digit
                display.text = digit
                userIsInTheMiddleOfTyping = true
                brain.newDigit(display.text)
            }
        }
        programTextView.text = brain.programDescription
    }
  
    @IBAction fileprivate func performOperation(_ sender: UIButton) {
        if let mathematicalSymbol = sender.currentTitle {
            if basicOperations.contains(mathematicalSymbol) {
                UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
                    sender.backgroundColor = ColorPalette.BasicOperation
                    }, completion: nil)
            } else {
                UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
                    sender.backgroundColor = ColorPalette.Operation
                    }, completion: nil)
            }
            if (userIsInTheMiddleOfTyping) {
                brain.setOperand(display.text)
                userIsInTheMiddleOfTyping = false
            }
            if pendingOperations.contains(mathematicalSymbol) {
                sender.backgroundColor = ColorPalette.BasicOperation
                pendingButton = sender
            }
            if cancelPendingOperations.contains(mathematicalSymbol) {
                if let b = pendingButton {
                    b.backgroundColor = ColorPalette.Operation
                }
            }
            brain.performOperation(mathematicalSymbol)
        }
        updateDisplay()
    }
    
    @IBAction func setBits(_ sender: AnyObject) {
        if let digits = Int(sender.currentTitle!!) {
            if digits != brain.digits {
                if digits <= brain.digits {
                    // make sure that the value in the display is used, even if the user has still been in the middle of typing
                    if (userIsInTheMiddleOfTyping) {
                        brain.setOperand(display.text)
                        userIsInTheMiddleOfTyping = false
                    }
                    brain.digits = digits
                } else {
                    // more digits --> reset
                    brain.digits = digits
                    brain.reset()
                }
                precisionTextView.text = "\(digits) digits"
                updateDisplay()
                layout()
                userIsInTheMiddleOfTyping = false
            }
            setPrecisionKeysBackgroundColor()
        }
    }
}
