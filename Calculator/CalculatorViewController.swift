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
    static let Operation = UIColor(red: 164.0/255.0, green: 164.0/255.0, blue: 164.0/255.0, alpha: 1.0)
    static let PressedOperation = UIColor(red: 217.0/255.0, green: 217.0/255.0, blue: 217.0/255.0, alpha: 1.0)
    static let Digits = UIColor(red: 52.0/255.0, green: 52.0/255.0, blue: 52.0/255.0, alpha: 1.0)
    static let PressedDigits = UIColor(red: 115.0/255.0, green: 115.0/255.0, blue: 115.0/255.0, alpha: 1.0)
}

struct DisplayFont {
    static let Tiny = UIFont.systemFont(ofSize: 10)
    static let Small = UIFont.systemFont(ofSize: 20)
    static let Normal = UIFont.systemFont(ofSize: 35)
}

let basicOperations = Set(["÷", "×", "−", "+", "="]) // for key colors
let pendingOperations = Set(["x^y", "x↑↑y"])
let cancelPendingOperations = Set(["C", "="])
let smallerScienceKeys = Set(["x^2", "x^3", "x^y", "e^x", "10^x", "√", "3√", "x↑↑y"])
let smallerBasicKeys = Set(["1/x", "±"])
let basicOperationKeys = Set(["1\\x", "±", "C"])

class CalculatorViewController: UIViewController {

    @IBOutlet weak var displayView: UIView!
    @IBOutlet weak var display: UITextView!

    @IBOutlet weak var keysView: UIView!
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
    @IBOutlet weak var numberOfDigitsControl: UISegmentedControl!
    @IBOutlet weak var sizeControl: UISegmentedControl!
    
    
    
    @IBOutlet weak var scienceStackWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var keysStackWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var keysStackHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var keyStackTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var keyStackTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var keyStackBottomConstraint: NSLayoutConstraint!
    
    fileprivate var userIsInTheMiddleOfTyping = false
    fileprivate let fmt = NumberFormatter()
    fileprivate var brain = CalculatorBrain()
    fileprivate var screenWidth:CGFloat = 300.0
    fileprivate var screenHeight:CGFloat = 300.0
    fileprivate var pendingButton: UIButton?
    var currentDeviceOrientation: UIDeviceOrientation = .unknown
    
    var displayNotExpanded = true
    var tapGestureRecognizer: UITapGestureRecognizer?

    fileprivate var savedProgram: CalculatorBrain.PropertyList?
    
   
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override var shouldAutorotate : Bool {
        return true
    }
    
    
    @objc func displayTouched() {
        if displayNotExpanded {
            keysView.isHidden = true
            numberOfDigitsControl.isHidden = true
            numberOfDigitsControl.isHidden = true
            sizeControl.isHidden = false
            displayNotExpanded = false
        } else {
            keysView.isHidden = false
            numberOfDigitsControl.isHidden = false
            displayNotExpanded = true
            numberOfDigitsControl.isHidden = false
            sizeControl.isHidden = true
        }
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.all
    }
    
    // MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sizeControl.isHidden = true
        sizeControl.selectedSegmentIndex = 2
        display.font = DisplayFont.Normal
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(displayTouched))
        tapGestureRecognizer!.numberOfTapsRequired = 1
        display.addGestureRecognizer(tapGestureRecognizer!)
        
        // Do any additional setup after loading the view, typically from a nib.
        display.indicatorStyle = UIScrollViewIndicatorStyle.white
        fmt.usesSignificantDigits = false
        fmt.maximumSignificantDigits = 10
        keysView.backgroundColor = UIColor.black
        displayView.backgroundColor = UIColor.black
        display.backgroundColor = UIColor.black

        let titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 16.0)]
        numberOfDigitsControl.setTitleTextAttributes(titleTextAttributes, for: .normal)
        numberOfDigitsControl.setTitleTextAttributes(titleTextAttributes, for: .selected)
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
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
//        layout()
    }

    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(CalculatorViewController.deviceDidRotate(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }

    @objc func deviceDidRotate(_ notification: Notification) {
        if self.currentDeviceOrientation != UIDevice.current.orientation {
            self.currentDeviceOrientation = UIDevice.current.orientation
            layout()
        }
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
    }
    
    
    override var prefersStatusBarHidden : Bool {
        return true;
    }
    
    func layout() {
        let spacing:CGFloat = 20
        
        screenWidth = view.frame.size.width
        screenHeight = view.frame.size.height
        if (screenWidth > screenHeight) {
            let temp:CGFloat = screenWidth
            screenWidth = screenHeight
            screenHeight = temp
        }
        scienceStackWidthConstraint.constant = screenHeight*0.6 - 0.5
        keyStackTrailingConstraint.constant = spacing
        keyStackTopConstraint.constant = spacing
        keyStackBottomConstraint.constant = spacing

        switch self.currentDeviceOrientation {
        case .landscapeLeft, .landscapeRight:
            scienceStack.isHidden = false
            keysStackWidthConstraint.constant = screenHeight*0.4
            keysStack.layoutIfNeeded()
//            if brain.digits < 50 {
//                displayViewHeightConstraint.constant =  screenWidth * 0.2
//                display.layoutIfNeeded()
//            } else {
//                displayViewHeightConstraint.constant =  screenWidth * 0.4
//                display.layoutIfNeeded()
//            }
        case .portrait, .portraitUpsideDown:
            scienceStack.isHidden = true
            
            // set the keyboard width and height
            keysStackWidthConstraint.constant = (screenWidth-2*spacing)
            keysStackHeightConstraint.constant = keysStackWidthConstraint.constant / 4 * 5
            keysStack.layoutIfNeeded()
        default:
            // do nothing
            return
        }

        keysStack.spacing = spacing
        ACStack.spacing = spacing
        _0Stack.spacing = spacing
        _123Stack.spacing = spacing
        _456Stack.spacing = spacing
        _789Stack.spacing = spacing

        let sizeX = (keysStack.frame.size.width-3*spacing) / 4
        let sizeY = (keysStack.frame.size.height-4*spacing) / 5
        let radius = min(sizeX, sizeY) / 2
        for stack in keysStack.subviews {
            for key in stack.subviews {
                if let b = key as? UIButton {
                    b.layer.cornerRadius = radius
//                    if b.tag == 2 { // 0
//                        b.frame.size.width = size + keysStack.frame.size.width / 4
//                    }
                }
            }
        }
        

        // font size
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
            inset = 0//fontSize / 3
        default:
            // do nothing
            return
        }
        let displayFontSize = min(fontSize, 30)
        buttonFont = UIFont.systemFont(ofSize: fontSize)
        largerButtonFont = UIFont.systemFont(ofSize: fontSize*1.2)
        displayFont = UIFont.systemFont(ofSize: displayFontSize)
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
                            // shift the 0 a bit to the right so that it aligns with the other digits
//                            b.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: size*0.38, bottom: 0, right: -size*0.38)
                        } else if b.tag == 3 {
                            b.setTitleColor(UIColor.white, for: UIControlState.normal)
                            b.setTitleColor(UIColor.white, for: UIControlState.highlighted)
                            titleLabel.font = largerButtonFont
                            b.backgroundColor = ColorPalette.BasicOperation
                            // lift the symbols up a bit
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
        sender.backgroundColor = ColorPalette.PressedOperation
    }
    @IBAction func digitTouchDown(_ sender: UIButton) {
        sender.backgroundColor = ColorPalette.PressedDigits
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
    
    var oldFontSize = 2

    @IBAction func sizeChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 3 {
            UIPasteboard.general.string = display.text

            sender.selectedSegmentIndex = oldFontSize
        }
        oldFontSize = sender.selectedSegmentIndex
        switch sender.selectedSegmentIndex {
        case 0:
            display.font = DisplayFont.Tiny
        case 1:
            display.font = DisplayFont.Small
        case 2:
            display.font = DisplayFont.Normal
        default:
            display.font = DisplayFont.Normal
        }
    }
    
    @IBAction func digitsControlChanged(_ sender: UISegmentedControl) {
        let digitsString = sender.titleForSegment(at: sender.selectedSegmentIndex)!
        if let digits = Int(digitsString.replacingOccurrences(of: ",", with: "")) {
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
                updateDisplay()
                userIsInTheMiddleOfTyping = false
            }
            setPrecisionKeysBackgroundColor()
        }
    }
}

