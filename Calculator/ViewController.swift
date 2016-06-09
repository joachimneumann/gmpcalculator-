//
//  ViewController.swift
//  Calculator
//
//  Created by Joachim Neumann on 09/05/2016.
//  Copyright © 2016 VISAMED IT. All rights reserved.
//

import UIKit

struct ColorPalette {
    static let BasicOperation = UIColor(red: 192.0/255.0, green: 203.0/255.0, blue: 156.0/255.0, alpha: 1.0)
    static let DarkBasicOperation = UIColor(red: 172.0/255.0, green: 183.0/255.0, blue: 136.0/255.0, alpha: 1.0)
    static let DarkOperation = UIColor(red: 192.0/255.0, green: 192.0/255.0, blue: 192.0/255.0, alpha: 1.0)
    static let Operation = UIColor(red: 217.0/255.0, green: 217.0/255.0, blue: 217.0/255.0, alpha: 1.0)
    static let Digits = UIColor(red: 217.0/255.0, green: 184.0/255.0, blue: 160.0/255.0, alpha: 1.0)
    static let DarkDigits = UIColor(red: 197.0/255.0, green: 164.0/255.0, blue: 140.0/255.0, alpha: 1.0)
}

class ViewController: UIViewController {

    @IBOutlet weak var display: UITextView!
    @IBOutlet weak var scienceStack: UIStackView!
    @IBOutlet weak var scienceStackWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var keysStack: UIStackView!
    @IBOutlet weak var keysStackWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var precisionStack: UIStackView!
    
    @IBOutlet weak var precisionTextView: UITextView!
    @IBOutlet weak var displayLabel: UIView!
    @IBOutlet weak var displayHeightConstraint: NSLayoutConstraint!
    private var userIsInTheMiddleOfTyping = false
    private let fmt = NSNumberFormatter()
    private var brain = CalculatorBrain()
    private var screenWidth:CGFloat = 300.0
    private var screenHeight:CGFloat = 300.0
    private var pendingButton: UIButton?
    var currentDeviceOrientation: UIDeviceOrientation = .Unknown

    let defaultPrecision = 75
    
    private var savedProgram: CalculatorBrain.PropertyList?
    
   
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
   
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.All
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layout()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        precisionTextView.text = "\(defaultPrecision) digits"
        precisionTextView.textContainerInset = UIEdgeInsetsZero;
        precisionTextView.textContainer.lineFragmentPadding = 0;
        UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.deviceDidRotate(_:)), name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        // Initial device orientation
        switch UIDevice.currentDevice().orientation {
        case .LandscapeRight:
            self.currentDeviceOrientation = .LandscapeRight
        case .LandscapeLeft:
            self.currentDeviceOrientation = .LandscapeLeft
        default:
            self.currentDeviceOrientation = .Portrait
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        if UIDevice.currentDevice().generatesDeviceOrientationNotifications {
            UIDevice.currentDevice().endGeneratingDeviceOrientationNotifications()
        }
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        switch UIDevice.currentDevice().orientation {
        case .LandscapeRight, .LandscapeLeft:
            setPrecisionKeysBackgroundColor()
        case .Portrait, .PortraitUpsideDown:
            if brain.digits != defaultPrecision {
                brain.digits = defaultPrecision
                precisionTextView.text = "\(defaultPrecision) digits"
                updateDisplay()
            }
        default: ()
        }
    }

    func deviceDidRotate(notification: NSNotification) {
        switch UIDevice.currentDevice().orientation {
        case .LandscapeRight:
            self.currentDeviceOrientation = .LandscapeRight
        case .LandscapeLeft:
            self.currentDeviceOrientation = .LandscapeLeft
        case .Portrait:
            self.currentDeviceOrientation = .Portrait
        case .PortraitUpsideDown:
            self.currentDeviceOrientation = .PortraitUpsideDown
        default: ()
        }
        layout()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        display.indicatorStyle = UIScrollViewIndicatorStyle.White
        fmt.usesSignificantDigits = false
        fmt.maximumSignificantDigits = 10
        screenWidth = view.frame.size.width
        screenHeight = view.frame.size.height
        if (screenWidth > screenHeight) {
            let temp:CGFloat = screenWidth
            screenWidth = screenHeight
            screenHeight = temp
        }
        scienceStackWidthConstraint.constant = screenHeight*0.6-1
        
        
        for stack in keysStack.subviews {
            for key in stack.subviews {
                if let b = key as? UIButton {
                    if let titleLabel = b.titleLabel {
                        if let titleText = titleLabel.text {
                            switch titleText {
                            case "1/x":
                                let image = UIImage(named: "1_x")
                                b.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
                                b.setImage(image, forState: UIControlState.Normal)
                            case "±":
                                let image = UIImage(named: "plus_minus")
                                b.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
                                b.setImage(image, forState: UIControlState.Normal)
                            default: ()
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
                                switch titleText {
                                case "x^2":
                                    let image = UIImage(named: "x_2")
                                    b.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
                                    b.setImage(image, forState: UIControlState.Normal)
                                case "x^3":
                                    let image = UIImage(named: "x_3")
                                    b.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
                                    b.setImage(image, forState: UIControlState.Normal)
                                case "x^y":
                                    let image = UIImage(named: "x_y")
                                    b.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
                                    b.setImage(image, forState: UIControlState.Normal)
                                case "e^x":
                                    let image = UIImage(named: "e_x")
                                    b.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
                                    b.setImage(image, forState: UIControlState.Normal)
                                case "10^x":
                                    let image = UIImage(named: "10_x")
                                    b.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
                                    b.setImage(image, forState: UIControlState.Normal)
                                case "√":
                                    let image = UIImage(named: "sqrt")
                                    b.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
                                    b.setImage(image, forState: UIControlState.Normal)
                                case "3√":
                                    let image = UIImage(named: "sqrt3")
                                    b.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
                                    b.setImage(image, forState: UIControlState.Normal)
                                case "x↑↑y":
                                    let image = UIImage(named: "x_arrow_arrow_y")
                                    b.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
                                    b.setImage(image, forState: UIControlState.Normal)
                                default: ()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func updateDisplay() {
        display!.text = brain.result.toString()
    }
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
    func layout() {
        switch self.currentDeviceOrientation {
        case .LandscapeLeft, .LandscapeRight:
            scienceStack.hidden = false
            keysStackWidthConstraint.constant = screenHeight*0.4
            if brain.digits < 50 {
                displayHeightConstraint.constant =  screenWidth * 0.2
            } else {
                displayHeightConstraint.constant =  screenWidth * 0.4
            }
        case .Portrait, .PortraitUpsideDown:
            scienceStack.hidden = true
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
        var buttonFont: UIFont
        var largeButtonFont: UIFont
        var displayFont: UIFont
        var buttonFontSize: CGFloat
        var largeButtonFontSize: CGFloat
        var inset: CGFloat
        switch self.currentDeviceOrientation {
        case .LandscapeLeft, .LandscapeRight:
            buttonFontSize = round(keysStack.bounds.size.height * 0.2 * 0.45)
            largeButtonFontSize = round(keysStack.bounds.size.height * 0.2 * 0.6)
            inset = buttonFontSize / 10
        case .Portrait, .PortraitUpsideDown:
            buttonFontSize = round(keysStack.bounds.size.height * 0.2 * 0.35)
            largeButtonFontSize = round(keysStack.bounds.size.height * 0.2 * 0.5)
            inset = buttonFontSize / 3
        default:
            // do nothing
            return
        }
        let displayFontSize = min(buttonFontSize, 30)
        buttonFont = UIFont(name: "HelveticaNeue-Thin", size: buttonFontSize)!
        largeButtonFont = UIFont(name: "HelveticaNeue-Thin", size: largeButtonFontSize)!
        displayFont = UIFont(name: "HelveticaNeue-Thin", size: displayFontSize)!
        for stack in scienceStack.subviews {
            for key in stack.subviews {
                if let b = key as? UIButton {
                    b.titleLabel?.bounds.height
                    b.titleLabel!.font = buttonFont
                    b.titleLabel!.adjustsFontSizeToFitWidth = true
                    if let titleLabel = b.titleLabel {
                        titleLabel.font = buttonFont
                        if let titleText = titleLabel.text {
                            switch titleText {
                            case "x^2", "x^3", "x^y", "e^x", "10^x", "√", "3√", "x↑↑y":
                                b.imageEdgeInsets = UIEdgeInsetsMake(inset, inset, inset, inset);
                            default: ()
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
                        if b.tag == 1 {
                            titleLabel.font = largeButtonFont
                            b.backgroundColor = ColorPalette.Digits
                        } else {
                            b.backgroundColor = ColorPalette.BasicOperation
                            titleLabel.font = buttonFont
                        }
                        if let titleText = titleLabel.text {
                            switch titleText {
                            case "1/x", "±":
                                b.imageEdgeInsets = UIEdgeInsetsMake(inset, inset, inset, inset);
                                b.backgroundColor = ColorPalette.Operation
                            case "C":
                                b.backgroundColor = ColorPalette.Operation
                            default: ()
                            }
                        }
                    }
                }
            }
            display.font = displayFont
        }
    }

    
    @IBAction func loadProgram() {
        if savedProgram != nil {
            brain.program = savedProgram!
            updateDisplay()
        }
    }
    
    @IBAction func saveProgram() {
        savedProgram = brain.program
    }
    
    @IBAction func basicOperationTouchDown(sender: UIButton) {
        sender.backgroundColor = ColorPalette.DarkBasicOperation
    }
    @IBAction func functionTouchDown(sender: UIButton) {
        sender.backgroundColor = ColorPalette.DarkOperation
    }
    @IBAction func digitTouchDown(sender: UIButton) {
        sender.backgroundColor = ColorPalette.DarkDigits
    }
    
    @IBAction private func touchDigit(sender: UIButton) {
        UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
            sender.backgroundColor = ColorPalette.Digits
            }, completion: nil)
        var digit = sender.currentTitle!
        let currentText = display.text!
        // zeros at the beginning (display is "0") are ignored
        if !(digit == "0" && currentText == "0") {
            if userIsInTheMiddleOfTyping {
                digit = (digit == "." && currentText.rangeOfString(".") != nil) ? "" : digit
                display.text = currentText + digit
            } else {
                digit = (digit == ".") ? "0." : digit
                display.text = digit
                userIsInTheMiddleOfTyping = true
            }
        }
    }

    func setPrecisionKeysBackgroundColor() {
        for subview in precisionStack.subviews {
            if let b = subview as? UIButton {
                if b.titleLabel!.text == String(brain.digits) {
                    b.backgroundColor = ColorPalette.BasicOperation
                    b.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                } else {
                    b.backgroundColor = ColorPalette.Operation
                    b.setTitleColor(UIColor.blackColor(), forState: .Normal)
                }
            }
        }
    }
    
    @IBAction private func performOperation(sender: UIButton) {
        if let mathematicalSymbol = sender.currentTitle {
            let basicOperations = Set(["÷", "×", "−", "+", "="])
            if basicOperations.contains(mathematicalSymbol) {
                UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
                    sender.backgroundColor = ColorPalette.BasicOperation
                    }, completion: nil)
            } else {
                UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
                    sender.backgroundColor = ColorPalette.Operation
                    }, completion: nil)
            }
            if (userIsInTheMiddleOfTyping) {
                brain.setOperand(display.text)
                userIsInTheMiddleOfTyping = false
            }
            let pendingOperations = Set(["x^y", "x↑↑y"])
            let cancelPendingOperations = Set(["C", "="])
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
    
    @IBAction func setBits(sender: AnyObject) {
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
