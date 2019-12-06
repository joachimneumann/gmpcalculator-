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
    @IBOutlet weak var keysStackBottom: NSLayoutConstraint!
    @IBOutlet weak var keysStackTrailing: NSLayoutConstraint!

    // strong, because I set isActive = false
    @IBOutlet var keysStackProportialHeight: NSLayoutConstraint!
    @IBOutlet var keysStackLeading: NSLayoutConstraint!
    
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

    var portrait: Bool {
        get {
            if UIDevice.current.orientation == .portrait {
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NSLog(portrait ? "viewWillAppear portrait: Yes" : "viewWillAppear portrait: No")
        NSLog(landscape ? "viewWillAppear landscape: Yes" : "viewWillAppear landscape: No")

        Brain.shared.precision = 100000
        Brain.shared.brainProtocolDelegate = self
        Brain.shared.reset() // display --> "0"
                
        display.textColor = .white
        display.contentMode = .bottom


        
    }
    
    override func viewDidLayoutSubviews() {
        NSLog(portrait  ? "viewDidLayoutSubviews  portrait: Yes" : "viewDidLayoutSubviews  portrait:  No")
        NSLog(landscape ? "viewDidLayoutSubviews landscape: Yes" : "viewDidLayoutSubviews landscape:  No")
        if landscape {
            spacing = view.bounds.size.height * 0.035
            keysStackLeading.isActive = false
            keysStackTrailing.constant = spacing * 1.2
            keysStackProportialHeight.isActive = true
            keysStackProportialHeight.constant = 0.6
        } else {
            spacing = view.bounds.size.width * 0.035
            keysStackLeading.isActive = true
            keysStackLeading.constant  = spacing * 1.2
            keysStackTrailing.constant = spacing * 1.2
            keysStackProportialHeight.isActive = false
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

        // make sure there is a bit of space at the bottom
        keysStackBottom.constant = spacing

        displayLeft.constant = 2 * spacing
        displayRight.constant = 2 * spacing

        if landscape {
            return
        }

        displayHeight.constant = view.frame.size.height * 0.1 * 20


        // if the keys ar too high, add space to the left and right,
        // which results in more space for the display
        if keysStack.frame.size.height / view.frame.size.height > 0.7 {
            spacing *= 1.1
            keysStackLeading.constant = spacing * 2
            keysStackTrailing.constant = spacing * 2
//            view.layoutIfNeeded()
            // NSLog("viewDidLayoutSubviews setNeedsLayout")
        } else {
            // NSLog("viewDidLayoutSubviews DONE")
            // if dispay is high enough, move the keys up
            // NSLog("viewDidLayoutSubviews %f", displayView.frame.size.height)
            if keysStack.frame.size.height / view.frame.size.height < 0.6 {
                keysStackBottom.constant = view.frame.size.height * 0.075
            }
        }
        let fontSize = keysStack.frame.size.height * 0.18
        display.font = UIFont.systemFont(ofSize: fontSize, weight: .thin)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}

