//
//  Brain.swift
//  Calculator
//
//  Created by Joachim Neumann on 21/09/2018.
//  Copyright © 2018 mindo software S.L. All rights reserved.
//

import Foundation

class Brain {
    
    struct OpStack {
        fileprivate var array: [String] = []
        mutating func push(_ element: String) {
            array.append(element)
        }
        mutating func pop() -> String? {
            return array.popLast()
        }
        func peek() -> String? {
            return array.last
        }
        func count() -> Int {
            return array.count
        }
        mutating func clean() {
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

    var twoParameterOpStack = OpStack()
    var n = GmpStack()

    fileprivate var nBits = 10
    
    var precision: Int {
        set {
            nBits = Int(round(Double(newValue) / 0.302))
        }
        get {
            return Int(round(Double(nBits) * 0.302))
        }
    }
    
    
    init() {
        // User: 1
        setDigit("1")
        assert(n.peek()! == Gmp("1", precision: nBits))
        // User: 0
        setDigit("10")
        assert(n.peek()! == Gmp("10", precision: nBits))
        // User: 1/x
        operation("1\\x")
        assert(n.peek()! == Gmp("0.1", precision: 10))

        // User: C
        reset()
        assert(n.peek() == nil)
        assert(twoParameterOpStack.count() == 0)
        
        // User: 1
        setDigit("1")
        assert(n.peek() == Gmp("1", precision: nBits))
        // User: +
        operation("+")
        // User: 2
        setDigit("2")
        // User: +
        operation("+")
        assert(n.peek() == Gmp("3", precision: 10))
        // User: 5
        setDigit("5")
        // User: +
        operation("+")
        assert(n.peek() == Gmp("8", precision: 10))
        // user: 2
        setDigit("2")
        // User: =
        operation("=")
        assert(n.peek() == Gmp("10", precision: 10))
        // User: +
        operation("+")
        assert(n.peek() == Gmp("10", precision: 10))
        // user: 4
        setDigit("4")
        // user: 1/x
        operation("1\\x")
        assert(n.peek() == Gmp("0.25", precision: 10))
        // User: =
        operation("=")
        assert(n.peek() == Gmp("10.25", precision: 10))
        
        reset()
        // User: 1
        setDigit("1")
        assert(n.peek() == Gmp("1", precision: nBits))
        // User: +
        operation("+")
        // User: 2
        setDigit("2")
        // User: *
        operation("*")
        assert(n.peek() == Gmp("2", precision: 10))
        // User: 5
        setDigit("4")
        assert(n.peek() == Gmp("4", precision: 10))
        // User: =
        operation("=")
        assert(n.peek() == Gmp("9", precision: 10))
        
        reset()
        // User: 1
        setDigit("1")
        assert(n.peek() == Gmp("1", precision: nBits))
        // User: +
        operation("+")
        // User: 2
        setDigit("2")
        // User: *
        operation("*")
        assert(n.peek() == Gmp("2", precision: 10))
        // User: 5
        setDigit("4")
        assert(n.peek() == Gmp("4", precision: 10))
        // User: +
        operation("+")
        assert(n.peek() == Gmp("9", precision: 10))
        // User: 100
        setDigit("100")
        assert(n.peek() == Gmp("100", precision: 10))
        // User: =
        operation("=")
        assert(n.peek() == Gmp("109", precision: 10))
    }
    
    func reset() {
        n.clean()
        twoParameterOpStack.clean()
    }
    func setDigit(_ digit: String) {
        n.push(Gmp(digit, precision: nBits))
    }

    func operation(_ symbol: String) {
        if symbol == "=" {
            while twoParameterOpStack.count() > 0 {
                let n1 = n.pop()!
                let n2 = n.pop()!
                let opName = twoParameterOpStack.pop()!
                let op = opDict[opName]!
                let n3 = op(n1,n2)
                n.push(n3)
            }
        } else if inplaceOp.contains(symbol) {
            if let op = inplaceDict[symbol] {
                let n1 = n.pop()!
                op(n1)
                n.push( n1 )
            }
        } else {
            if twoParameterOp.keys.contains(symbol) {
                // do I need to calculate pending things?
                var conditionsMet = true
                while conditionsMet {
                    if n.count() <= 1 { conditionsMet = false }
                    if twoParameterOpStack.count() == 0 { conditionsMet = false }
                    let op1 = symbol
                    if conditionsMet {
                        let op2 = twoParameterOpStack.peek()!
                        let op1h = twoParameterOp[op1]!
                        let op2h = twoParameterOp[op2]!
                        if op2h < op1h { conditionsMet = false }
                    }
                    if conditionsMet {
                        if let opName = twoParameterOpStack.pop() {
                            if let op = opDict[opName] {
                                let n1 = n.pop()!
                                let n2 = n.pop()!
                                let n3 = op(n1, n2)
                                n.push(n3)
                            }
                        }
                    }
                }
                twoParameterOpStack.push(symbol)
            }
        }
    }

    fileprivate var inplaceDict: Dictionary< String, (Gmp) -> () > = [
        "1\\x": rez
    ]

    fileprivate let twoParameterOp: Dictionary < String, Int> = [
        "+": 1,
        "*": 2
    ]
    
    fileprivate let inplaceOp = Set(["1\\x"])

    fileprivate var opDict: Dictionary< String, (Gmp, Gmp) -> (Gmp) > = [
        "+": add,
        "*": mul
    ]

}
