//
//  Brain.swift
//  Calculator
//
//  Created by Joachim Neumann on 21/09/2018.
//  Copyright © 2018 mindo software S.L. All rights reserved.
//


import Foundation

protocol BrainProtocol {
    func pendingOperator(name: String)
    func endPendingOperator(name: String)
    func updateDisplay(s: String)
}

class Brain {
    let debug = false
    var lastWasDigit = false
    private var display_private: String
    var display: String  {
        set {
            display_private = newValue
            brainProtocolDelegate?.updateDisplay(s: display_private)
        }
        get {
            return display_private
        }
    }
    
    var brainProtocolDelegate: BrainProtocol? {
        set {
            op.brainProtocolDelegate = newValue
        }
        get {
            return op.brainProtocolDelegate
        }
    }
    
    struct OpStack {
        var brainProtocolDelegate: BrainProtocol? = nil
        fileprivate var array: [String] = []
        mutating func push(_ element: String) {
            brainProtocolDelegate?.pendingOperator(name: element)
            array.append(element)
        }
        mutating func pop() -> String? {
            if let last = array.last {
                brainProtocolDelegate?.endPendingOperator(name: last)
            }
            return array.popLast()
        }
        
        mutating func removeLast() {
            if let last = array.last {
                brainProtocolDelegate?.endPendingOperator(name: last)
            }
            array.removeLast()
        }
        
        func peek() -> String? {
            return array.last
        }
        func count() -> Int {
            return array.count
        }
        mutating func clean() {
            for s in array {
                brainProtocolDelegate?.endPendingOperator(name: s)
            }
            array.removeAll()
        }
    }
    
    struct GmpStack {
        fileprivate var array: [Gmp] = []
        mutating func push(_ element: Gmp) {
            array.append(element)
        }
        mutating func pop() -> Gmp? {
            return array.popLast()
        }
        mutating func removeLast() {
            array.removeLast()
        }
        func peek() -> Gmp? {
            return array.last
        }
        func count() -> Int {
            return array.count
        }
        mutating func clean() {
            array.removeAll()
        }
    }

    var op = OpStack()
    var n = GmpStack()

    fileprivate var nBits = 0
    
    var precision: Int {
        // throwing in 20 addition bits, this helps with sin(asin) to result in identity
        set {
            nBits = Int(round(Double(newValue) / 0.302)) + 20
        }
        get {
            return Int(round(Double(nBits-20) * 0.302))
        }
    }
    
    
    func test() {
        precision = 75

        // 1 / 10
        digit("1")
        digit("0")
        operation("1\\x")
        assert(n.peek()! == Gmp("0.1", precision: nBits))
        digit("1")
        assert(n.peek()! == Gmp("1", precision: nBits))
        digit("6")
        assert(n.peek()! == Gmp("16", precision: nBits))
        operation("1\\x")
        assert(n.peek()! == Gmp("0.0625", precision: nBits))
        
        // clear
        reset()
        assert(n.peek() == nil)
        assert(op.count() == 0)
        
        // 1+2+5+2= + 1/4 =
        digit("1")
        assert(n.peek() == Gmp("1", precision: nBits))
        operation("+")
        assert(n.peek() == Gmp("1", precision: nBits))
        digit("2")
        operation("+")
        assert(n.peek() == Gmp("3", precision: nBits))
        digit("5")
        operation("+")
        assert(n.peek() == Gmp("8", precision: nBits))
        digit("2")
        operation("=")
        assert(n.peek() == Gmp("10", precision: nBits))
        operation("+")
        assert(n.peek() == Gmp("10", precision: nBits))
        digit("4")
        operation("1\\x")
        assert(n.peek() == Gmp("0.25", precision: nBits))
        operation("=")
        assert(n.peek() == Gmp("10.25", precision: nBits))

        // 1+2*4=
        reset()
        digit("1")
        assert(n.peek() == Gmp("1", precision: nBits))
        operation("+")
        digit("2")
        operation("×")
        assert(n.peek() == Gmp("2", precision: nBits))
        digit("4")
        assert(n.peek() == Gmp("4", precision: nBits))
        operation("=")
        assert(n.peek() == Gmp("9", precision: nBits))
        
        reset()
        digit("1")
        assert(n.peek() == Gmp("1", precision: nBits))
        operation("+")
        digit("2")
        operation("×")
        assert(n.peek() == Gmp("2", precision: nBits))
        digit("4")
        assert(n.peek() == Gmp("4", precision: nBits))
        operation("+")
        assert(n.peek() == Gmp("9", precision: nBits))
        digit("1")
        digit("0")
        digit("0")
        assert(n.peek() == Gmp("100", precision: nBits))
        // User: =
        operation("=")
        assert(n.peek() == Gmp("109", precision: nBits))
        
        reset()
        operation("π")
        operation("×")
        digit("2")
        operation("=")
        
        reset()
        digit("2")
        operation("pow_x_y")
        digit("1")
        digit("0")
        operation("=")
        assert(n.peek() == Gmp("1024", precision: nBits))
        reset()
    }
    
    init() {
        display_private = "0"
        reset()
        if debug { test() }
    }
    

    func reset() {
        n.clean()
        op.clean()
        display = "0"
        lastWasDigit = false
        brainProtocolDelegate?.updateDisplay(s: display)
    }

    func digit(_ digit: String) {
        assert(digit.count == 1)
        if lastWasDigit {
            var ignore = false

            // if the display contains a dot, ignore further dots
            if display.range(of: ".") != nil && digit == "." { ignore = true }

            // If the display is "0", set display to digit
            if display == "0" { display = digit; ignore = true }

            if !ignore {
                display = display + digit
            }
            if n.count() > 0 { n.removeLast() }
            n.push(Gmp(display, precision: nBits))
        } else {
            display = digit
            n.push(Gmp(display, precision: nBits))
        }
        lastWasDigit = true

        if debug { print("replaceDigit \(digit) \(n)") }
    }

    func operation(_ symbol: String) {
        if symbol == "C" {
            reset()
        } else if symbol == "=" {
            while op.count() > 0 && n.count() >= 2 {
                let n1 = n.pop()!
                let n2 = n.pop()!
                let opName = op.pop()!
                let operation = opDict[opName]!
                let n3 = operation(n2,n1)
                n.push(n3)
                display = n3.toString()
            }
            n.clean()
            op.clean()
            brainProtocolDelegate?.updateDisplay(s: display)
            n.push(Gmp(display, precision: nBits))
        } else if inplaceDict.keys.contains(symbol) {
            if let op = inplaceDict[symbol] {
                let n1 = Gmp(display, precision: nBits)
                op(n1)
                if n.count() > 0 { n.removeLast() }
                n.push(n1)
                display = n1.toString()
                brainProtocolDelegate?.updateDisplay(s: display)
            }
        } else if constDict.keys.contains(symbol) {
            if let op = constDict[symbol] {
                let n1 = Gmp("0", precision: nBits)
                op(n1)
                n.push(n1)
                display = n1.toString()
                brainProtocolDelegate?.updateDisplay(s: display)
            }
        } else {
            if twoParameterOp.keys.contains(symbol) {
                // do I need to calculate pending things?
                var conditionsMet = true
                while conditionsMet {
                    if n.count() <= 1 { conditionsMet = false }
                    if op.count() == 0 { conditionsMet = false }
                    let op1 = symbol
                    if conditionsMet {
                        let op2 = op.peek()!
                        let op1h = twoParameterOp[op1]!
                        let op2h = twoParameterOp[op2]!
                        if op2h < op1h { conditionsMet = false }
                    }
                    if conditionsMet {
                        if let opName = op.pop() {
                            if let op = opDict[opName] {
                                let n1 = n.pop()!
                                let n2 = n.pop()!
                                let n3 = op(n2, n1)
                                n.push(n3)
                                display = n3.toString()
                                brainProtocolDelegate?.updateDisplay(s: display)
                            }
                        }
                    }
                }
                op.push(symbol)
            }
        }
        if debug { print("operation    \(symbol) \(op)") }
        lastWasDigit = false
    }

    fileprivate var inplaceDict: Dictionary< String, (Gmp) -> () > = [
        "±": changeSign,
        "1\\x": rez,
        "x!": fac,
        "Z": Z,
        "ln": ln,
        "log10": log10,
        "√": sqrt,
        "3√": sqrt3,
        "sin": sin,
        "cos": cos,
        "tan": tan,
        "asin": asin,
        "acos": acos,
        "atan": atan,
        "x^2": pow_x_2,
        "x^3": pow_x_3,
        "e^x": pow_e_x,
        "10^x": pow_10_x
    ]

    fileprivate var constDict: Dictionary< String, (Gmp) -> () > = [
        "π": π,
        "e": e,
        "γ": γ,
    ]

    fileprivate let twoParameterOp: Dictionary < String, Int> = [
        "+": 1,
        "−": 1,
        "×": 2,
        "÷": 2,
        "x^y": 2,
        "pow_x_y": 2,
        "x↑↑y": 2
    ]
    
    fileprivate var opDict: Dictionary< String, (Gmp, Gmp) -> (Gmp) > = [
        "+": add,
        "−": min,
        "×": mul,
        "÷": div,
        "x^y": pow_x_y,
        "pow_x_y": pow_x_y,
        "x↑↑y": x_double_up_arrow_y
    ]
}
