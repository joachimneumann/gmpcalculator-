//
//  CalculatorViewController.swift
//  Calculator
//
//  Created by Joachim Neumann on 09/05/2016.
//  Copyright © 2016 mindo software S.L. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController, BrainProtocol {
    
    @IBOutlet weak var zoomButton: UIButton!
    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var pasteButton: UIButton!
    @IBOutlet weak var upButton: UIButton!
    @IBOutlet weak var upButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var downButton: UIButton!
    @IBOutlet weak var downButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var largeDisplay: UITextView!
    @IBOutlet weak var displayLeft: NSLayoutConstraint!
    @IBOutlet weak var displayRight: NSLayoutConstraint!
    @IBOutlet weak var displayHeight: NSLayoutConstraint!

    @IBOutlet weak var stackView02: UIStackView!
    @IBOutlet weak var stackView01: UIStackView!
    
    @IBOutlet weak var keysStack: UIStackView!
    @IBOutlet weak var keysStackWidth: NSLayoutConstraint!
    @IBOutlet weak var keysStackHeight: NSLayoutConstraint!
    @IBOutlet weak var keysStackBottom: NSLayoutConstraint!
    @IBOutlet weak var keysStackTrailing: NSLayoutConstraint!
    @IBOutlet weak var keysStackAspectRatio: NSLayoutConstraint!
    
    @IBOutlet weak var extraKeysStack: UIStackView!
    @IBOutlet weak var extraKeysStackLeading: NSLayoutConstraint!
    @IBOutlet weak var extraKeysStackWidth: NSLayoutConstraint!

    fileprivate var calculatorKeys = Dictionary<String, CalculatorKey>()
    fileprivate var spacing: CGFloat = 0
    fileprivate var zoom = false
    fileprivate var landscape: Bool {
        get {
            if UIDevice.current.orientation == .landscapeRight ||
                UIDevice.current.orientation == .landscapeLeft {
                return true
            }
            return false
        }
    }

    func pendingOperator(name: String) {
        if let key = calculatorKeys[name] {
            key.pending = true
        }
    }
    
    func endPendingOperator(name: String) {
        if let key = calculatorKeys[name] {
            key.pending = false
        }
    }
    
    func updateDisplay(s: String) {
        display.text = s
        if !largeDisplay.isHidden {
            largeDisplay.text = Brain.shared.longString()
        }
    }
    
    @IBAction func upPressed(_ sender: Any) {
        largeDisplay.scrollRangeToVisible(NSMakeRange(0,0))
    }
    
    @IBAction func downPressed(_ sender: Any) {
        if largeDisplay.text.count > 0 {
            let location = largeDisplay.text.count - 1
            let bottom = NSMakeRange(location, 1)
            largeDisplay.scrollRangeToVisible(bottom)
        }
    }
    
    @IBAction func zoomPressed(_ sender: Any) {
        if zoom {
            zoomButton.setImage(UIImage(named: "zoom_out"), for: .normal)
            keysStack.isHidden = false
            if UIScreen.main.bounds.width > UIScreen.main.bounds.height {
                extraKeysStack.isHidden = false
            } else {
                extraKeysStack.isHidden = true
            }
            display.isHidden = false
            copyButton.isHidden = true
            pasteButton.isHidden = true
            upButton.isHidden = true
            downButton.isHidden = true
            largeDisplay.isHidden = true
        } else {
            zoomButton.setImage(UIImage(named: "zoom_in"), for: .normal)
            copyButton.isHidden = false
            pasteButton.isHidden = false
            largeDisplay.text = Brain.shared.longString()
            largeDisplay.scrollRangeToVisible(NSMakeRange(0,0))
            if largeDisplay.contentSize.height > largeDisplay.frame.size.height {
                upButton.isHidden = false
                upButtonTopConstraint.constant = largeDisplay.frame.origin.y + 0.2 * upButton.frame.size.height
                downButton.isHidden = false
                downButtonTopConstraint.constant = largeDisplay.frame.origin.y + largeDisplay.frame.size.height - 1.2 * downButton.frame.size.height
            } else {
                upButton.isHidden = true
                downButton.isHidden = true
            }
            largeDisplay.isHidden = false
            keysStack.isHidden = true
            extraKeysStack.isHidden = true
            display.isHidden = true
        }
        zoom = !zoom
    }
    
    @IBAction func copyToClipboard(_ sender: UIButton) {
        self.copyButton.setTitleColor(.orange, for: .normal)
        self.copyButton.setTitleColor(.orange, for: .highlighted)
        self.largeDisplay.textColor = .orange
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            self.largeDisplay.textColor = .white
            self.copyButton.setTitleColor(.lightGray, for: .normal)
            self.copyButton.setTitleColor(.orange, for: .highlighted)
        })
        let pasteboard = UIPasteboard.general
        pasteboard.string = largeDisplay.text
    }

    @IBAction func copyFromClipboard(_ sender: UIButton) {
        let pasteboard = UIPasteboard.general
        if let s = pasteboard.string {
            if Brain.shared.fromLongString(s) {
                self.pasteButton.setTitleColor(.orange, for: .normal)
                self.pasteButton.setTitleColor(.orange, for: .highlighted)
                self.largeDisplay.textColor = .orange
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                    self.pasteButton.setTitleColor(.lightGray, for: .normal)
                    self.pasteButton.setTitleColor(.orange, for: .highlighted)
                    self.largeDisplay.textColor = .white
                })
            } else {
                self.pasteButton.setTitle("invalid", for: .normal)
                self.pasteButton.setTitle("invalid", for: .highlighted)
                self.pasteButton.setTitleColor(.orange, for: .normal)
                self.pasteButton.setTitleColor(.orange, for: .highlighted)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                    self.pasteButton.setTitle("paste", for: .normal)
                    self.pasteButton.setTitle("paste", for: .highlighted)
                    self.pasteButton.setTitleColor(.lightGray, for: .normal)
                    self.pasteButton.setTitleColor(.orange, for: .highlighted)
                })
            }
        }
    }
    

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for horizontalStack in keysStack.subviews {
            for element in horizontalStack.subviews {
                if let key = element as? CalculatorKey {
                    calculatorKeys[key.buttonTitle] = key
                }
                if let stack = element as? UIStackView {
                    for element in stack.subviews {
                        if let key = element as? CalculatorKey {
                            calculatorKeys[key.buttonTitle] = key
                        }
                    }
                }
            }
        }
        for horizontalStack in extraKeysStack.subviews {
            for element in horizontalStack.subviews {
                if let key = element as? CalculatorKey {
                    calculatorKeys[key.buttonTitle] = key
                }
            }
        }
        self.copyButton.setTitleColor(.lightGray, for: .normal)
        self.copyButton.setTitleColor(.orange, for: .highlighted)
        self.pasteButton.setTitleColor(.lightGray, for: .normal)
        self.pasteButton.setTitleColor(.orange, for: .highlighted)
    }
    
    override var shouldAutorotate : Bool {
        return true
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.allButUpsideDown
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { (_) in
            self.layoutWithNewScreenSize()
        }, completion: nil)
    }

    func layoutWithNewScreenSize(){
        let w = UIScreen.main.bounds.width
        let h = UIScreen.main.bounds.height
        print("SCREEN RESOLUTION: "+w.description+" x "+h.description)
        if w > h {
            // landscape
            let sidemargin = w - zoomButton.frame.origin.x + 10
            keysStackTrailing.constant = sidemargin
            keysStackAspectRatio.isActive = false
            keysStackWidth.constant = 0.37 * w
            keysStackHeight.constant = 0.7 * h
            if h - keysStackHeight.constant < 150 {
                keysStackHeight.constant = h - 150
            }
            keysStackHeight.isActive = true
            CalculatorKey.landscape = true
            spacing = h * 0.02
            displayLeft.constant = sidemargin + 10
            displayRight.constant = sidemargin + 10

            extraKeysStack.isHidden = keysStack.isHidden
            extraKeysStackLeading.constant = sidemargin
            let spaceBetweenKeys = 3 * spacing
            extraKeysStackWidth.constant =
                w -
                sidemargin -
                spaceBetweenKeys -
                keysStackWidth.constant -
                keysStackTrailing.constant
            extraKeysStack.spacing = spacing
            for v in extraKeysStack.subviews {
                if let stack = v as? UIStackView {
                    stack.spacing = spacing
                }
            }
        } else {
            // portrait
            keysStackHeight.isActive = false
            keysStackAspectRatio.isActive = true
            CalculatorKey.landscape = false
            spacing = w * 0.035
            var newTrailing = spacing * 1.2
            var newWidth = w - 2 * newTrailing
            // keys too high?
            if newWidth / keysStackAspectRatio.multiplier > 0.7 * h {
                newWidth = 0.7 * h * keysStackAspectRatio.multiplier
                newTrailing = (w - newWidth) / 2
            }
            keysStackTrailing.constant = newTrailing
            keysStackWidth.constant = newWidth
            displayLeft.constant  = 2 * spacing
            displayRight.constant = 2 * spacing
            extraKeysStack.isHidden = true
        }

        // distance between the keys
        keysStack.spacing = spacing
        for v in keysStack.subviews {
            if let stack = v as? UIStackView {
                stack.spacing = spacing
            }
        }
        stackView02.spacing = spacing
        stackView01.spacing = spacing

        var fontSize = keysStackWidth.constant * 0.2
        display.font = UIFont.monospacedSystemFont(ofSize: fontSize, weight: .thin)
        fontSize = min(w,h) * 0.04
        largeDisplay.font = UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
        copyButton.titleLabel?.font = largeDisplay.font
        pasteButton.titleLabel?.font = largeDisplay.font
        if !upButton.isHidden {
            upButtonTopConstraint.constant = largeDisplay.frame.origin.y + 0.2 * upButton.frame.size.height
        }
        if !downButton.isHidden {
            downButtonTopConstraint.constant = largeDisplay.frame.origin.y + largeDisplay.frame.size.height - 1.2 * downButton.frame.size.height
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Brain.shared.precision = 100000
        Brain.shared.brainProtocolDelegate = self
        Brain.shared.reset() // display --> "0"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        layoutWithNewScreenSize()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}

