//
//  CalculatorViewController.swift
//  Calculator
//
//  Created by Joachim Neumann on 09/05/2016.
//  Copyright © 2016 mindo software S.L. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var verticalStack: UIStackView!
    @IBOutlet weak var display: UITextView!
    
    @IBOutlet weak var stackView02: UIStackView!
    @IBOutlet weak var stackView01: UIStackView!
    
    @IBOutlet weak var verticalStackBottom: NSLayoutConstraint!
    @IBOutlet weak var verticalStackLeading: NSLayoutConstraint!
    @IBOutlet weak var verticalStackTrailing: NSLayoutConstraint!
    
    var spacing: CGFloat = 0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override var shouldAutorotate : Bool {
        return true
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.allButUpsideDown
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == display {
            print("You edit myTextField")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        display.delegate = self
        
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
    }
    
    override func viewDidLayoutSubviews() {
        // if dispay is high enough, move the keys up
        NSLog("viewDidLayoutSubviews %f", display.frame.size.height)
        if display.frame.size.height / view.frame.size.height > 0.4 {
            verticalStackBottom.constant = view.frame.size.height * 0.075
        }
        
        // if the display is not high enough, add space to the left and right,
        // which results in more space for the display
        if display.frame.size.height / view.frame.size.height < 0.25 {
            spacing *= 1.1
            verticalStackLeading.constant = spacing * 2
            verticalStackTrailing.constant = spacing * 2
//            view.setNeedsLayout()
            view.layoutIfNeeded()
            NSLog("viewDidLayoutSubviews setNeedsLayout")
        } else {
            NSLog("viewDidLayoutSubviews DONE")
        }
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}

