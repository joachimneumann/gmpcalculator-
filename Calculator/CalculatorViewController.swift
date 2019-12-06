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
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var largeDisplay: UITextView!
    @IBOutlet weak var displayLeft: NSLayoutConstraint!
    @IBOutlet weak var displayRight: NSLayoutConstraint!
    @IBOutlet weak var displayHeight: NSLayoutConstraint!

    @IBOutlet weak var stackView02: UIStackView!
    @IBOutlet weak var stackView01: UIStackView!
    
    @IBOutlet weak var keysStack: UIStackView!
    @IBOutlet weak var keysStackWidth: NSLayoutConstraint!
    @IBOutlet weak var keysStackBottom: NSLayoutConstraint!
    @IBOutlet weak var keysStackTrailing: NSLayoutConstraint!
    
    @IBOutlet weak var extraKeysStack: UIStackView!
    @IBOutlet weak var extraKeysStackLeading: NSLayoutConstraint!
    @IBOutlet weak var extraKeysStackWidth: NSLayoutConstraint!

    
    fileprivate var spacing: CGFloat = 0
    var zoom = false
    var landscape: Bool {
        get {
            if UIDevice.current.orientation == .landscapeRight ||
                UIDevice.current.orientation == .landscapeLeft {
                return true
            }
            return false
        }
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
    
    func updateDisplay(s: String) {
        display.text = s
    }
    
    @IBAction func copyPressed(_ sender: Any) {
    }
    
    @IBAction func zoomPressed(_ sender: Any) {
        if zoom {
            zoomButton.setImage(UIImage(named: "zoom_out"), for: .normal)
            keysStack.isHidden = false
            display.isHidden = false
            copyButton.isHidden = true
            largeDisplay.isHidden = true
        } else {
            zoomButton.setImage(UIImage(named: "zoom_in"), for: .normal)
            copyButton.isHidden = false
            largeDisplay.text = Brain.shared.longString()
            largeDisplay.isHidden = false
            keysStack.isHidden = true
            display.isHidden = true
        }
        zoom = !zoom
    }
    
    struct PotentiallyPendingOperator {
        let b: UIButton
        let normalBackgroundColor: UIColor
        let highlightedBackgroundColor: UIColor
    }
    var potentiallyPending: Dictionary<String,PotentiallyPendingOperator>

    required init?(coder aDecoder: NSCoder) {
        potentiallyPending = [:]
        super.init(coder: aDecoder)
    }
    
    override var shouldAutorotate : Bool {
        return true
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.allButUpsideDown
    }

    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        getScreenSize()
        print(fromInterfaceOrientation)
    }
    func getScreenSize(){
        let w = UIScreen.main.bounds.width
        let h = UIScreen.main.bounds.height
        print("SCREEN RESOLUTION: "+w.description+" x "+h.description)
        if w > h {
            // landscape
            let sidemargin = w - zoomButton.frame.origin.x + 10
            keysStackTrailing.constant = sidemargin
            keysStackWidth.constant = 0.58 * h
            spacing = h * 0.02
            displayLeft.constant = sidemargin + 10
            displayRight.constant = sidemargin + 10

            extraKeysStackLeading.constant = sidemargin
            let oneKeyWidth = (keysStackWidth.constant - 3 * spacing) / 4.0
            extraKeysStackWidth.constant =
                w -
                sidemargin -
                oneKeyWidth -
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
            spacing = w * 0.035
            keysStackTrailing.constant = spacing * 1.2
            keysStackWidth.constant = w - 2 * keysStackTrailing.constant
            displayLeft.constant  = 2 * spacing
            displayRight.constant = 2 * spacing
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

        let fontSize = keysStackWidth.constant * 0.2
        display.font = UIFont.monospacedSystemFont(ofSize: fontSize, weight: .thin)
        largeDisplay.font = UIFont.monospacedSystemFont(ofSize: fontSize/4, weight: .regular)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Brain.shared.precision = 100000
        Brain.shared.brainProtocolDelegate = self
        Brain.shared.reset() // display --> "0"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getScreenSize()
    }
    
//    override func viewDidLayoutSubviews() {
//        return
//        NSLog(portrait  ? "viewDidLayoutSubviews  portrait: Yes" : "viewDidLayoutSubviews  portrait:  No")
//        NSLog(landscape ? "viewDidLayoutSubviews landscape: Yes" : "viewDidLayoutSubviews landscape:  No")
//        if landscape {
//            spacing = view.bounds.size.height * 0.035
//            keysStackLeading.isActive = false
//            keysStackTrailing.constant = spacing * 1.2
////            keysStackProportialHeight.isActive = true
////            keysStackProportialHeight.constant = 0.6
//        } else {
//            spacing = view.bounds.size.width * 0.035
//            keysStackLeading.isActive = true
//            keysStackLeading.constant  = spacing * 1.2
//            keysStackTrailing.constant = spacing * 1.2
////            keysStackProportialHeight.isActive = false
//        }
//
//        // distance between the keys
//        keysStack.spacing = spacing
//        for v in keysStack.subviews {
//            if let stack = v as? UIStackView {
//                stack.spacing = spacing
//            }
//        }
//        stackView02.spacing = spacing
//        stackView01.spacing = spacing
//
//        // make sure there is a bit of space at the bottom
//        keysStackBottom.constant = spacing
//
//        displayLeft.constant = 2 * spacing
//        displayRight.constant = 2 * spacing
//
//        if landscape {
//            return
//        }
//
//        displayHeight.constant = view.frame.size.height * 0.1 * 20
//
//
//        // if the keys ar too high, add space to the left and right,
//        // which results in more space for the display
//        if keysStack.frame.size.height / view.frame.size.height > 0.7 {
//            spacing *= 1.1
//            keysStackLeading.constant = spacing * 2
//            keysStackTrailing.constant = spacing * 2
////            view.layoutIfNeeded()
//            // NSLog("viewDidLayoutSubviews setNeedsLayout")
//        } else {
//            // NSLog("viewDidLayoutSubviews DONE")
//            // if dispay is high enough, move the keys up
//            // NSLog("viewDidLayoutSubviews %f", displayView.frame.size.height)
//            if keysStack.frame.size.height / view.frame.size.height < 0.6 {
//                keysStackBottom.constant = view.frame.size.height * 0.075
//            }
//        }
//    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}

