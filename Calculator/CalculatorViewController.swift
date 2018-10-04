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
    static let Tiny   = UIFont.monospacedDigitSystemFont(ofSize: 10, weight: UIFont.Weight.medium)
    static let Small  = UIFont.monospacedDigitSystemFont(ofSize: 20, weight: UIFont.Weight.medium)
    static let Normal = UIFont.monospacedDigitSystemFont(ofSize: 35, weight: UIFont.Weight.medium)
}

let smallerBasicKeys = Set(["1/x", "±"])
let basicOperationKeys = Set(["1\\x", "±", "C"])

class CalculatorViewController: UIViewController, BrainProtocol  {

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
    
    @IBOutlet weak var sinKey: UIButton!
    @IBOutlet weak var key_75: UIButton!
    @IBOutlet weak var key_normal: UIButton!
    @IBOutlet weak var key_Z: UIButton!
    
    @IBOutlet weak var controlView: UIView!
    @IBOutlet weak var controlKeysView: UIView!
    @IBOutlet weak var controlKey100000: UIButton!
    
    @IBOutlet weak var digitsStack: UIStackView!
    @IBOutlet weak var displayStack: UIStackView!
    
    @IBOutlet weak var controlViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var controlViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var controlViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var controlKeysViewTopConstraint: NSLayoutConstraint!

    @IBOutlet weak var controlsKeysViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var controlKeysViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var displayViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var displayViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var keysViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var keysViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var keysViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var keysStackTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var keysStackWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var keyStackTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var keyStackBottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var scienceStackWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var scienceStackLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var scienceStackTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var scienceStackBottomConstraint: NSLayoutConstraint!
    
    fileprivate var spacing: CGFloat = 20
    fileprivate let fmt = NumberFormatter()
    fileprivate var brain = Brain()
    fileprivate var screenWidth: CGFloat = 300.0
    fileprivate var screenHeight :CGFloat = 300.0
    fileprivate var buttonFont: UIFont?
    fileprivate var largerButtonFont: UIFont?
    fileprivate var currentDeviceOrientation: UIDeviceOrientation = .unknown
    
    var displayExpanded = false
    var tapGestureRecognizer: UITapGestureRecognizer?

    required init?(coder aDecoder: NSCoder) {
        potentiallyPending = [:]
        super.init(coder: aDecoder)
    }
    
    override var shouldAutorotate : Bool {
        return true
    }
    
    struct PotentiallyPendingOperator {
        let b: UIButton
        let normalBackgroundColor: UIColor
        let highlightedBackgroundColor: UIColor
    }
    
    var potentiallyPending: Dictionary<String,PotentiallyPendingOperator>
    
    @objc func displayTouched() {
        if displayExpanded {
            displayExpanded = false
        } else {
            displayExpanded = true
        }
        setDisplay()
    }

    func setDisplay() {
        var bottomSpace: CGFloat = 0
        var allSpace: CGFloat = 0
        switch UIApplication.shared.statusBarOrientation {
        case .portrait, .portraitUpsideDown:
            allSpace = screenHeight
            bottomSpace = controlView.frame.size.height
        case .landscapeLeft, .landscapeRight:
            allSpace = screenWidth
            bottomSpace = 0
        default: break
        }
        if displayExpanded {
            keysView.isHidden = true
            digitsStack.isHidden = true
            displayStack.isHidden = true
            displayStack.isHidden = false
            displayViewHeightConstraint.constant =
                allSpace - bottomSpace
        } else {
            keysView.isHidden = false
            digitsStack.isHidden = false
            displayStack.isHidden = true
            displayViewHeightConstraint.constant =
                allSpace -
                keysView.frame.size.height -
            bottomSpace
        }
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.all
    }
    
    // MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        brain.precision = 75
        brain.brainProtocolDelegate = self
        brain.reset() // display --> "0"

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
                                if titleText == "+" {
                                    potentiallyPending["+"] =
                                        PotentiallyPendingOperator(
                                            b: b,
                                            normalBackgroundColor: ColorPalette.BasicOperation,
                                            highlightedBackgroundColor: ColorPalette.PressedBasicOperation)
                                }
                                if titleText == "−" {
                                    potentiallyPending["−"] =
                                        PotentiallyPendingOperator(
                                            b: b,
                                            normalBackgroundColor: ColorPalette.BasicOperation,
                                            highlightedBackgroundColor: ColorPalette.PressedBasicOperation)
                                }
                                if titleText == "×" {
                                    potentiallyPending["×"] =
                                        PotentiallyPendingOperator(
                                            b: b,
                                            normalBackgroundColor: ColorPalette.BasicOperation,
                                            highlightedBackgroundColor: ColorPalette.PressedBasicOperation)
                                }
                                if titleText == "÷" {
                                    potentiallyPending["÷"] =
                                        PotentiallyPendingOperator(
                                            b: b,
                                            normalBackgroundColor: ColorPalette.BasicOperation,
                                            highlightedBackgroundColor: ColorPalette.PressedBasicOperation)
                                }
                                if titleText == "x^y" {
                                    potentiallyPending["x^y"] =
                                        PotentiallyPendingOperator(
                                            b: b,
                                            normalBackgroundColor: ColorPalette.ExtendedOperation,
                                            highlightedBackgroundColor: ColorPalette.PressedExtendedOperation)
                                }
                                if titleText == "x↑↑y" {
                                    potentiallyPending["x↑↑y"] =
                                        PotentiallyPendingOperator(
                                            b: b,
                                            normalBackgroundColor: ColorPalette.ExtendedOperation,
                                            highlightedBackgroundColor: ColorPalette.PressedExtendedOperation)
                                }
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
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(CalculatorViewController.deviceDidRotate(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)

        // screenHeight is ALWAYS larger than screenWidth
        screenWidth = view.frame.size.width
        screenHeight = view.frame.size.height
        if (screenWidth > screenHeight) {
            let temp:CGFloat = screenWidth
            screenWidth = screenHeight
            screenHeight = temp
        }

        layout()
        
        precisionButtonPressed(key_75)
        sizeChanged(key_normal)
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
    
    func updateDisplay(s: String) {
        display!.text = s
    }
    
    
    override var prefersStatusBarHidden : Bool {
        return true;
    }
    
    func landscaleLayout() {
        scienceStack.isHidden = false
        keysStack.layoutIfNeeded()
        // control keys should have the same height as the normal keys
        let controlWidth = screenHeight*0.15
        digitsStack.axis = .vertical
        displayStack.axis = .vertical
        keysViewLeadingConstraint.constant = controlWidth
        displayViewLeadingConstraint.constant = controlWidth
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
        keysView.layoutIfNeeded()
        displayViewHeightConstraint.constant = screenWidth - keysView.frame.size.height
        let controlHeight = 4*sinKey.frame.size.height + 3 * spacing
        controlsKeysViewTrailingConstraint.constant = 0
        controlKeysViewLeadingConstraint.constant = spacing
        controlViewBottomConstraint.constant = (screenWidth-controlHeight)/2
        controlViewHeightConstraint.constant = controlHeight
        controlViewWidthConstraint.constant = controlWidth
        digitsStack.distribution = .fillEqually
    }
    func portraitLayout() {
        controlViewBottomConstraint.constant = 0
        displayViewLeadingConstraint.constant = 0
        scienceStack.isHidden = true
        digitsStack.axis = .horizontal
        displayStack.axis = .horizontal
        let controlHeight = screenHeight*0.08 // 8%
        keysViewBottomConstraint.constant = controlHeight
        keysViewLeadingConstraint.constant = 0
        keysStackWidthConstraint.constant = screenWidth-2*spacing
        keysView.layoutIfNeeded()
        var w = keysStackWidthConstraint.constant / 4 * 5
        if w > screenHeight * 0.6 {
            w = screenHeight * 0.6
        }
        keysViewHeightConstraint.constant = w
        keysView.layoutIfNeeded()
        controlsKeysViewTrailingConstraint.constant = spacing
        controlKeysViewLeadingConstraint.constant = spacing
        controlViewHeightConstraint.constant = controlHeight
        controlViewWidthConstraint.constant = screenWidth
        controlView.layoutIfNeeded()
        displayViewHeightConstraint.constant = screenHeight - keysView.frame.size.height - controlView.frame.size.height
        digitsStack.distribution = .fillProportionally
    }

    func pendingOperator(name: String) {
        if let op = potentiallyPending[name] {
            op.b.backgroundColor = op.highlightedBackgroundColor
        }
    }
    
    func endPendingOperator(name: String) {
        if let op = potentiallyPending[name] {
            op.b.backgroundColor = op.normalBackgroundColor
        }
    }
    
    func backgroundForKey(button: UIButton, fontSize: CGFloat) {
        var inset: CGFloat
        switch UIDevice.current.orientation {
        case .landscapeLeft, .landscapeRight:
            inset = fontSize / 10
        case .portrait, .portraitUpsideDown:
            inset = 0//fontSize / 3
        default:
            // do nothing
            return
        }
        if let titleLabel = button.titleLabel {
            switch button.tag {
            case 0: // C +/- 1/x
                button.setTitleColor(UIColor.black, for: UIControlState())
                titleLabel.font = buttonFont
                button.backgroundColor = ColorPalette.Operation
            case 1: // digits 1 to 9
                button.setTitleColor(UIColor.white, for: UIControlState())
                titleLabel.font = buttonFont
                button.backgroundColor = ColorPalette.Digits
            case 2: // 0
                button.setTitleColor(UIColor.white, for: UIControlState())
                titleLabel.font = buttonFont
                button.backgroundColor = ColorPalette.Digits
                // shift the 0 a bit to the right so that it aligns with the other digits
                // b.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: size*0.38, bottom: 0, right: -size*0.38)
            case 3: // / x - + =
                button.setTitleColor(UIColor.white, for: UIControlState())
                titleLabel.font = largerButtonFont
                button.backgroundColor = ColorPalette.BasicOperation
                // lift the symbols up a bit
                button.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: fontSize*0.1, right: 0)
            case 4: // X^2 sin etc
                button.setTitleColor(UIColor.white, for: UIControlState())
                titleLabel.font = buttonFont
                button.backgroundColor = ColorPalette.ExtendedOperation
                // lift the symbols up a bit
                button.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: fontSize*0.1, right: 0)
            default:
                button.setTitleColor(UIColor.black, for: UIControlState())
                titleLabel.font = buttonFont
            }
            if let titleText = titleLabel.text {
                if smallerBasicKeys.contains(titleText) {
                    button.imageEdgeInsets = UIEdgeInsetsMake(inset, inset, inset, inset);
                }
                if basicOperationKeys.contains(titleText) {
                    button.backgroundColor = ColorPalette.Operation
                }
            }
        }
    }

    func layout() {
        switch UIDevice.current.orientation {
        case .landscapeLeft, .landscapeRight:
            spacing = 0.02 * screenHeight
            landscaleLayout()
        case .portrait, .portraitUpsideDown:
            spacing = 0.02 * screenHeight
            portraitLayout()
        default:
            // do nothing
            return
        }
        setDisplay()

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
        digitsStack.spacing = spacing
        
        keysView.layoutIfNeeded()
        controlKeysView.layoutIfNeeded()
        
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
        for v in controlKeysView.subviews {
            for stack in v.subviews {
                if let b = stack as? UIButton {
                    let sizeX = b.frame.size.width
                    let sizeY = b.frame.size.height
                    let radius = min(sizeX, sizeY) / 4
                    b.layer.cornerRadius = radius
                }
            }
        }

        view.layoutIfNeeded()
        
        // font size
        var fontSize: CGFloat
        switch UIDevice.current.orientation {
        case .landscapeLeft, .landscapeRight:
            fontSize = round(keysStack.bounds.size.height * 0.07)
        case .portrait, .portraitUpsideDown:
            fontSize = round(keysStack.bounds.size.height * 0.07)
        default:
            // do nothing
            return
        }
        
        buttonFont = UIFont.systemFont(ofSize: fontSize)
        largerButtonFont = UIFont.systemFont(ofSize: fontSize*1.2)
        
        for v in keysView.subviews {
            for stack in v.subviews {
                for key in stack.subviews {
                    if let b = key as? UIButton {
                        backgroundForKey(button: b, fontSize: fontSize)
                    }
                }
            }
        }
        for v in controlKeysView.subviews {
            for stack in v.subviews {
                if let b = stack as? UIButton {
                    b.setTitleColor(UIColor.white, for: UIControlState())
                    // lift the symbols up a bit
                    b.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: fontSize*0.1, right: 0)
                }
            }
        }
        controlView.layoutIfNeeded()
        var controlKeyFontSize: CGFloat
        controlKeyFontSize = round(controlKey100000.frame.size.width * 0.15)
        for v in controlKeysView.subviews {
            for stack in v.subviews {
                if let b = stack as? UIButton {
                    b.titleLabel!.font = UIFont.monospacedDigitSystemFont(ofSize: controlKeyFontSize, weight: UIFont.Weight.medium)
                }
            }
        }

    }
    
    @IBAction func basicOperationTouchDown(_ sender: UIButton) {
        sender.backgroundColor = ColorPalette.PressedBasicOperation
    }
    
    @IBAction func functionTouchDown(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            sender.backgroundColor = ColorPalette.PressedOperation
        case 3:
            sender.backgroundColor = ColorPalette.PressedOperation
        case 4:
            sender.backgroundColor = ColorPalette.PressedExtendedOperation
        default:
            sender.backgroundColor = ColorPalette.PressedExtendedOperation
        }
    }
    
    @IBAction func digitTouchDown(_ sender: UIButton) {
        sender.backgroundColor = ColorPalette.PressedDigits
    }
    
    
    @IBAction fileprivate func touchDigit(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
            sender.backgroundColor = ColorPalette.Digits
            }, completion: nil
        )
        brain.digit((sender.titleLabel?.text)!)
    }
  
    @IBAction fileprivate func performOperation(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
            switch sender.tag {
            case 0:
                sender.backgroundColor = ColorPalette.Operation
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
            brain.operation(mathematicalSymbol)
        }
    }
    
    @IBAction func copyToClipboard(_ sender: UIButton) {
        let t = 0.1
        UIView.transition(with: self.display, duration: t, options: .transitionCrossDissolve, animations: {
            self.display.textColor = UIColor.orange
        }, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2*t, execute: {
            UIView.transition(with: self.display, duration: t, options: .transitionCrossDissolve, animations: {
                self.display.textColor = UIColor.white
            }, completion: nil)
      })
        let pasteboard = UIPasteboard.general
        pasteboard.string = display.text
    }

    @IBAction func sizeChanged(_ sender: UIButton) {
        for k in displayStack.subviews {
            if let key = k as? UIButton {
                key.backgroundColor = ColorPalette.Digits
            }
        }
        sender.backgroundColor = ColorPalette.BasicOperation
        switch sender.titleLabel?.text {
        case "tiny":
            display.font = DisplayFont.Tiny
        case "small":
            display.font = DisplayFont.Small
        case "normal":
            display.font = DisplayFont.Normal
        default:
            display.font = DisplayFont.Normal
        }
    }
    
    @IBAction func precisionButtonPressed(_ sender: UIButton) {
        // all digits buttons to not_active
        for k in digitsStack.subviews {
            if let key = k as? UIButton {
                key.backgroundColor = ColorPalette.Digits
            }
        }
        sender.backgroundColor = ColorPalette.BasicOperation
        if let s1 = sender.titleLabel?.text! {
            let s2 = s1.replacingOccurrences(of: ",", with: "")
            let s3 = s2.replacingOccurrences(of: " ", with: "")
            if let precision = Int(s3) {
                if precision != brain.precision {
                    brain.precision = precision
                    if brain.precision > 1000 {
                        key_Z.isEnabled = false
                        key_Z.setTitleColor(UIColor.gray, for: UIControlState())
                    } else {
                        key_Z.isEnabled = true
                        key_Z.setTitleColor(UIColor.white, for: UIControlState())
                    }
                }
            }
        }
    }

}

