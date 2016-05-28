//
//  ViewController.swift
//  Calculator
//
//  Created by Joachim Neumann on 09/05/2016.
//  Copyright © 2016 VISAMED IT. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    @IBOutlet weak var display: UITextView!
    @IBOutlet weak var displayDescription: UILabel!
    @IBOutlet weak var scienceStack: UIStackView!
    @IBOutlet weak var scienceStackWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var keysStack: UIStackView!
    @IBOutlet weak var keysStackWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var displayLabel: UIView!
    @IBOutlet weak var displayHeightConstraint: NSLayoutConstraint!
    private var userIsInTheMiddleOfTypeing = false
    private let fmt = NSNumberFormatter()
    private var brain = CalculatorBrain()
    private var screenWidth:CGFloat = 300.0
    private var screenHeight:CGFloat = 300.0

    private var displayValue: Gmp
    
    
    private var savedProgram: CalculatorBrain.PropertyList?
    
   
    required init?(coder aDecoder: NSCoder) {
        displayValue = Gmp(0.0, precision: brain.nBits)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        display.indicatorStyle = UIScrollViewIndicatorStyle.White
        fmt.usesSignificantDigits = false
        fmt.maximumSignificantDigits = 10
        switch UIDevice.currentDevice().orientation {
        case .LandscapeLeft, .LandscapeRight:
            screenWidth = view.frame.size.width
            screenHeight = view.frame.size.height
        default:
            screenWidth = view.frame.size.width
            screenHeight = view.frame.size.height
        }
        if (screenWidth > screenHeight) {
            let temp:CGFloat = screenWidth
            screenWidth = screenHeight
            screenHeight = temp
        }
        displayDescription.hidden = true
    }
    
    func updateDisplay() {
        display!.text = displayValue.toString()
        displayDescription.text = brain.description
    }
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
    func layout() {
        switch UIDevice.currentDevice().orientation{
        case .LandscapeLeft, .LandscapeRight:
            scienceStack.hidden = false
            keysStackWidthConstraint.constant = screenWidth*0.6
            scienceStackWidthConstraint.constant = screenHeight - keysStackWidthConstraint.constant-1
            if brain.nBits < 100 {
                displayHeightConstraint.constant =  screenWidth * 0.2
            } else if brain.nBits <= 1000 {
                displayHeightConstraint.constant =  screenWidth * 0.3
            } else {
                displayHeightConstraint.constant =  screenWidth * 0.4
            }
        default: // portrait
            scienceStack.hidden = true
            keysStackWidthConstraint.constant = screenWidth
            scienceStackWidthConstraint.constant = screenHeight - screenWidth-1
            if brain.nBits < 100 {
                displayHeightConstraint.constant =  screenHeight * 0.2
            } else {
                displayHeightConstraint.constant =  screenHeight * 0.3
            }
        }
        view.layoutIfNeeded()
        keyFontSize()
    }
    
    func keyFontSize() {
        var buttonFont: UIFont
        var displayFont: UIFont
        let buttonFontSize: CGFloat = round(keysStack.bounds.size.height * 0.2 * 0.4)
        let displayFontSize = min(buttonFontSize, 30)
        buttonFont = UIFont(name: "HelveticaNeue-Thin", size: buttonFontSize)!
        displayFont = UIFont(name: "HelveticaNeue-Thin", size: displayFontSize)!
        for stack in scienceStack.subviews {
            for key in stack.subviews {
                if let b = key as? UIButton {
                    b.titleLabel?.bounds.height
                    b.titleLabel!.font = buttonFont
                    b.titleLabel!.adjustsFontSizeToFitWidth = true
                    
                }
            }
        }
        for stack in keysStack.subviews {
            for key in stack.subviews {
                if let b = key as? UIButton {
                    b.titleLabel!.font = buttonFont
                }
            }
        }
        display.font = displayFont
    }
    

    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        layout()
    }
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        keyFontSize()
    }
    
    @IBAction func loadProgram() {
        if savedProgram != nil {
            brain.program = savedProgram!
            displayValue = brain.result
            updateDisplay()
//            displayDescription.text = brain.description
        }
    }
    
    @IBAction func saveProgram() {
        savedProgram = brain.program
    }
    
    @IBAction private func touchDigit(sender: UIButton) {
        var digit = sender.currentTitle!
        let currentText = display.text!
        // zeros at the beginning (display is "0") are ignored
        if !(digit == "0" && currentText == "0") {
            if userIsInTheMiddleOfTypeing {
                digit = (digit == "." && currentText.rangeOfString(".") != nil) ? "" : digit
                display.text = currentText + digit
            } else {
                digit = (digit == ".") ? "0." : digit
                display.text = digit
                userIsInTheMiddleOfTypeing = true
            }
        }
//        displayDescription.text = brain.description
        displayValue = Gmp(display.text!, precision: brain.nBits)
    }

    @IBAction func setBits(sender: AnyObject) {
        let bits = Int(sender.currentTitle ?? "100") ?? 100
        brain.nBits = bits
        layout()
        displayValue = Gmp(0.0, precision: brain.nBits)
        if bits == 53 {
            display.text = "precision set double"
        } else {
            display.text = "precision set to \(bits) bits"
        }
    }
    
    @IBAction private func performOperation(sender: UIButton) {
        if (userIsInTheMiddleOfTypeing) {
            displayValue = Gmp(display.text!, precision: brain.nBits)
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTypeing = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            if mathematicalSymbol == "AC" {
                brain.reset()
            }
            brain.performOperation(mathematicalSymbol)
        }
        displayValue = brain.result
        updateDisplay()
    }
}
