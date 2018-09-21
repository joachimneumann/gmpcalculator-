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
    static let ExtendedOperation = UIColor(red: 33.0/255.0, green: 33.0/255.0, blue: 33.0/255.0, alpha: 1.0)
    static let PressedExtendedOperation = UIColor(red: 80.0/255.0, green: 80.0/255.0, blue: 80.0/255.0, alpha: 1.0)
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
    @IBOutlet weak var science5Stack: UIStackView!
    
    @IBOutlet weak var keysStack: UIStackView!
    @IBOutlet weak var ACStack: UIStackView!
    @IBOutlet weak var _789Stack: UIStackView!
    @IBOutlet weak var _456Stack: UIStackView!
    @IBOutlet weak var _123Stack: UIStackView!
    @IBOutlet weak var _0Stack: UIStackView!
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var digitsStack: UIStackView!
    @IBOutlet weak var displayStack: UIStackView!
    
    @IBOutlet weak var displayViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var scienceStackWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var scienceStackLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var scienceStackTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var keysViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var keysViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var keysViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var keysStackTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var keysStackWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var keyStackTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var keyStackBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var scienceStackBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var displayViewBottomConstraint: NSLayoutConstraint!
    
    fileprivate let spacing:CGFloat = 20
    fileprivate var userIsInTheMiddleOfTyping = false
    fileprivate let fmt = NumberFormatter()
    fileprivate var brain = CalculatorBrain()
    fileprivate var screenWidth:CGFloat = 300.0
    fileprivate var screenHeight:CGFloat = 300.0
    fileprivate var pendingButton: UIButton?
    fileprivate var buttonFont: UIFont?
    fileprivate var largerButtonFont: UIFont?
    fileprivate var displayFont: UIFont?
    fileprivate var currentDeviceOrientation: UIDeviceOrientation = .unknown
    
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
            digitsStack.isHidden = true
            displayStack.isHidden = true
            displayStack.isHidden = false
            displayNotExpanded = false
        } else {
            keysView.isHidden = false
            digitsStack.isHidden = false
            displayStack.isHidden = true
            displayNotExpanded = true
        }
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.all
    }
    
    // MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        digitsStack.isHidden = false
        displayStack.isHidden = true
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

        for v in keysView.subviews {
            for stack in v.subviews {
                for key in stack.subviews {
                    if let b = key as? UIButton {
                        if let titleLabel = b.titleLabel {
                            if let titleText = titleLabel.text {
                                if let beginUIImage = UIImage(named: titleText) {
                                    b.imageView?.contentMode = UIViewContentMode.scaleAspectFit
                                    b.setImage(beginUIImage, for: UIControlState())
                                }
                            }
                        }
                    }
                }
            }
        }
        layout()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(CalculatorViewController.deviceDidRotate(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        switch self.currentDeviceOrientation {
        case .landscapeLeft:
            landscaleLayout()
        case .landscapeRight:
            landscaleLayout()
        default:
            portraitLayout()
        }
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
    
    func landscaleLayout() {
        scienceStack.isHidden = false
        let bottomViewHeight = 3*spacing+4*25
        let bottomViewWidth:CGFloat = 90
        bottomViewHeightConstraint.constant = bottomViewHeight
        bottomViewBottomConstraint.constant = screenWidth/2 - bottomViewHeight/2
        bottomViewLeadingConstraint.constant = spacing/2
        bottomViewWidthConstraint.constant = bottomViewWidth
        digitsStack.axis = .vertical
        displayStack.axis = .vertical
        keysViewLeadingConstraint.constant = bottomViewWidth+spacing/2
        displayViewLeadingConstraint.constant = bottomViewWidth+spacing/2
        keysViewBottomConstraint.constant = 0
        keysViewBottomConstraint.constant = 0
        keysView.layoutIfNeeded()
        keysStackWidthConstraint.constant = keysView.frame.size.width*0.5-1.5*spacing
        keysStack.layoutIfNeeded()
        keysViewHeightConstraint.constant = screenWidth*0.6
        keysStack.layoutIfNeeded()
        scienceStack.layoutIfNeeded()
        scienceStackWidthConstraint.constant  = keysView.frame.size.width*0.5-1.5*spacing
        scienceStack.layoutIfNeeded()
        scienceStackLeadingConstraint.constant = spacing
        scienceStackTopConstraint.constant = spacing
        scienceStackBottomConstraint.constant = spacing
    }
    func portraitLayout() {
        displayViewLeadingConstraint.constant = 0
        bottomViewBottomConstraint.constant = 0
        scienceStack.isHidden = true
        digitsStack.axis = .horizontal
        displayStack.axis = .horizontal
        keysViewBottomConstraint.constant = 40
        keysViewLeadingConstraint.constant = 0
        bottomViewLeadingConstraint.constant = spacing
        bottomViewHeightConstraint.constant = 40
        bottomViewWidthConstraint.constant = screenWidth-2*spacing
        keysStackWidthConstraint.constant = screenWidth-2*spacing
        keysStack.layoutIfNeeded()
        keysViewHeightConstraint.constant = keysStackWidthConstraint.constant / 4 * 5
        keysStack.layoutIfNeeded()
    }

    func layout() {
        // screenHeight is ALWAYS larger than screenWidth
        screenWidth = view.frame.size.width
        screenHeight = view.frame.size.height
        if (screenWidth > screenHeight) {
            let temp:CGFloat = screenWidth
            screenWidth = screenHeight
            screenHeight = temp
        }
        
        switch self.currentDeviceOrientation {
        case .landscapeLeft, .landscapeRight:
            landscaleLayout()
        case .portrait, .portraitUpsideDown:
            portraitLayout()
        default:
            // do nothing
            return
        }

        keyStackTrailingConstraint.constant = spacing
        keyStackBottomConstraint.constant = spacing
        keysStackTopConstraint.constant = spacing

        keysStack.spacing = spacing
        ACStack.spacing = spacing
        _0Stack.spacing = spacing
        _123Stack.spacing = spacing
        _456Stack.spacing = spacing
        _789Stack.spacing = spacing
        scienceStack.spacing = spacing
        science1Stack.spacing = spacing
        science2Stack.spacing = spacing
        science3Stack.spacing = spacing
        science4Stack.spacing = spacing
        science5Stack.spacing = spacing
        displayStack.spacing = 0.5*spacing
        digitsStack.spacing = 0.5*spacing
        
        keysView.layoutIfNeeded()
        
        for v in keysView.subviews {
            for stack in v.subviews {
                for key in stack.subviews {
                    if let b = key as? UIButton {
                        let sizeX = b.frame.size.width
                        let sizeY = b.frame.size.height
                        let radius = min(sizeX, sizeY) / 2
                        b.layer.cornerRadius = radius
                    }
                }
            }
        }
        for v in bottomView.subviews {
            for stack in v.subviews {
                if let b = stack as? UIButton {
                    let sizeX = b.frame.size.width
                    let sizeY = b.frame.size.height
                    let radius = min(sizeX, sizeY) / 4
                    b.layer.cornerRadius = radius
                }
            }
        }


        // font size
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
        
        switch self.currentDeviceOrientation {
        case .landscapeLeft, .landscapeRight:
            for v in bottomView.subviews {
                for stack in v.subviews {
                    if let b = stack as? UIButton {
                        b.titleLabel!.font = buttonFont
                    }
                }
            }
        case .portrait, .portraitUpsideDown:
            for v in bottomView.subviews {
                for stack in v.subviews {
                    if let b = stack as? UIButton {
                        b.titleLabel!.font = DisplayFont.Small
                    }
                }
            }
        default:
            // do nothing
            return
        }

        for v in keysView.subviews {
            for stack in v.subviews {
                for key in stack.subviews {
                    if let b = key as? UIButton {
                        if let titleLabel = b.titleLabel {
                            // tag 1: digits 1 to 9
                            // tag 2: 0
                            // tag 3: / x - + =
                            // tag 4: X^2 sin etc
                            // tag 0: all other
                            switch b.tag {
                            case 1:
                                b.setTitleColor(UIColor.white, for: UIControlState())
                                titleLabel.font = buttonFont
                                b.backgroundColor = ColorPalette.Digits
                            case 2:
                                b.setTitleColor(UIColor.white, for: UIControlState())
                                titleLabel.font = buttonFont
                                b.backgroundColor = ColorPalette.Digits
                                // shift the 0 a bit to the right so that it aligns with the other digits
    //                            b.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: size*0.38, bottom: 0, right: -size*0.38)
                            case 3:
                                b.setTitleColor(UIColor.white, for: UIControlState.normal)
                                b.setTitleColor(UIColor.white, for: UIControlState.highlighted)
                                titleLabel.font = largerButtonFont
                                b.backgroundColor = ColorPalette.BasicOperation
                                // lift the symbols up a bit
                                b.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: fontSize*0.1, right: 0)
                            case 4:
                                b.setTitleColor(UIColor.white, for: UIControlState.normal)
                                b.setTitleColor(UIColor.white, for: UIControlState.highlighted)
                                titleLabel.font = buttonFont
                                b.backgroundColor = ColorPalette.ExtendedOperation
                                // lift the symbols up a bit
                                b.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: fontSize*0.1, right: 0)
                            default:
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
            }
            display.font = displayFont
        }
        for v in bottomView.subviews {
            for stack in v.subviews {
                if let b = stack as? UIButton {
                    b.setTitleColor(UIColor.white, for: UIControlState.normal)
                    b.setTitleColor(UIColor.white, for: UIControlState.highlighted)
                    b.backgroundColor = ColorPalette.BasicOperation
                    // lift the symbols up a bit
                    b.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: fontSize*0.1, right: 0)
                }
            }
        }

    }

    
    
    @IBAction func basicOperationTouchDown(_ sender: UIButton) {
        sender.backgroundColor = ColorPalette.PressedBasicOperation
    }
    @IBAction func functionTouchDown(_ sender: UIButton) {
        if sender.tag == 3 {
            sender.backgroundColor = ColorPalette.PressedOperation
        } else {
            sender.backgroundColor = ColorPalette.PressedExtendedOperation
        }
    }
    @IBAction func digitTouchDown(_ sender: UIButton) {
        sender.backgroundColor = ColorPalette.PressedDigits
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
        UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
            switch sender.tag {
            case 2:
                sender.backgroundColor = ColorPalette.Operation
            case 3:
                sender.backgroundColor = ColorPalette.BasicOperation
            case 4:
                sender.backgroundColor = ColorPalette.ExtendedOperation
            default:
                break
            }
        }, completion: nil)
        if let mathematicalSymbol = sender.currentTitle {
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
    
    @IBAction func copyToClipboard(_ sender: UIButton) {
        let pasteboard = UIPasteboard.general
        pasteboard.string = display.text
    }

    @IBAction func sizeChanged(_ sender: UIButton) {
        switch sender.titleLabel?.text {
        case "Tiny":
            display.font = DisplayFont.Tiny
        case "Small":
            display.font = DisplayFont.Small
        case "Normal":
            display.font = DisplayFont.Normal
        default:
            display.font = DisplayFont.Normal
        }
    }
    
    @IBAction func digitsButtonPressed(_ sender: UIButton) {
        if let digitsString = sender.titleLabel?.text! {
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
            }
        }
    }

}

