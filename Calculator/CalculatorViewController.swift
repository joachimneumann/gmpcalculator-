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
    @IBOutlet weak var verticalStack: UIStackView!
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var displayLeft: NSLayoutConstraint!
    @IBOutlet weak var displayRight: NSLayoutConstraint!
    @IBOutlet weak var displayBottom: NSLayoutConstraint!
    @IBOutlet weak var displayHeight: NSLayoutConstraint!

    @IBOutlet weak var stackView02: UIStackView!
    @IBOutlet weak var stackView01: UIStackView!
    
    @IBOutlet weak var verticalStackBottom: NSLayoutConstraint!
    @IBOutlet weak var verticalStackLeading: NSLayoutConstraint!
    @IBOutlet weak var verticalStackTrailing: NSLayoutConstraint!
    
    fileprivate var spacing: CGFloat = 0
    var zoom = false
    
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
        display.text = Brain.shared.longToShort(l: s)
    }
    
    @IBAction func copyPressed(_ sender: Any) {
    }
    
    @IBAction func zoomPressed(_ sender: Any) {
        if zoom {
            zoomButton.setImage(UIImage(named: "zoom_out"), for: .normal)
            copyButton.isHidden = true
            verticalStack.isHidden = false
            display.isHidden = false
        } else {
            zoomButton.setImage(UIImage(named: "zoom_in"), for: .normal)
            copyButton.isHidden = false
            verticalStack.isHidden = true
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

        Brain.shared.precision = 100000
        Brain.shared.brainProtocolDelegate = self
        Brain.shared.reset() // display --> "0"
                
        spacing = view.bounds.size.width * 0.035
        
        // make sure there is a bit of space to the left and right of the keys
        if verticalStack.frame.origin.x < spacing * 1.2 {
            verticalStackLeading.constant  = spacing * 1.2
            verticalStackTrailing.constant = spacing * 1.2
        }
        // make sure there is a bit of space at the bottom
        verticalStackBottom.constant = spacing
//        if view.frame.size.height - verticalStack.frame.origin.y - verticalStack.frame.size.height < spacing {
//            verticalStackBottom.constant = spacing
//        }
        
        verticalStack.spacing = spacing
        for v in verticalStack.subviews {
            if let stack = v as? UIStackView {
                stack.spacing = spacing
            }
        }
        stackView02.spacing = spacing
        stackView01.spacing = spacing
        
        displayLeft.constant = 2 * spacing
        displayRight.constant = 2 * spacing
        displayBottom.constant = 0
        displayHeight.constant = view.frame.size.height * 0.1 * 20
        display.textColor = .white
        display.contentMode = .bottom
    }
    
    override func viewDidLayoutSubviews() {
        
        // if the keys ar too high, add space to the left and right,
        // which results in more space for the display
        if verticalStack.frame.size.height / view.frame.size.height > 0.7 {
            spacing *= 1.1
            verticalStackLeading.constant = spacing * 2
            verticalStackTrailing.constant = spacing * 2
            view.layoutIfNeeded()
            // NSLog("viewDidLayoutSubviews setNeedsLayout")
        } else {
            // NSLog("viewDidLayoutSubviews DONE")
            // if dispay is high enough, move the keys up
            // NSLog("viewDidLayoutSubviews %f", displayView.frame.size.height)
            if verticalStack.frame.size.height / view.frame.size.height < 0.6 {
                verticalStackBottom.constant = view.frame.size.height * 0.075
            }
        }
        let fontSize = verticalStack.frame.size.height * 0.18
        display.font = UIFont.systemFont(ofSize: fontSize, weight: .thin)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}

