//
//  Brain.swift
//  Calculator
//
//  Created by Joachim Neumann on 21/09/2018.
//  Copyright © 2018 mindo software S.L. All rights reserved.
//

import Foundation

class Brain {
    
    struct Stack {
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

    var main: Gmp?
    var second: Gmp?
    var opStack = Stack()
    
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
        assert(main! == Gmp("1", precision: nBits))
        // User: 0
        setDigit("10")
        assert(main! == Gmp("10", precision: nBits))
        // User: 1/x
        operation("1\\x")
        assert(main == Gmp("0.1", precision: 10))

        // User: C
        reset()
        assert(main == nil)
        assert(second == nil)
        assert(opStack.count() == 0)
        
        // User: 1
        setDigit("1")
        assert(main! == Gmp("1", precision: nBits))
        // User: +
        operation("+")
        // User: 2
        setDigit("2")
        // User: +
        operation("+")
        assert(main == Gmp("3", precision: 10))
        // User: 5
        setDigit("5")
        // User: +
        operation("+")
        assert(main == Gmp("8", precision: 10))
        setDigit("2")
        // User: +
        operation("=")
        assert(main == Gmp("10", precision: 10))
    }
    
    func reset() {
        main = nil
        second = nil
        opStack.clean()
    }
    func setDigit(_ digit: String) {
        if main != nil {
            second = main
        }
        main = Gmp(digit, precision: nBits)
    }

    func operation(_ symbol: String) {
        if symbol == "=" {
            if second != nil && main != nil && opStack.count() > 0 {
                if let opName = opStack.pop() {
                    if let op = opDict[opName] {
                        main = op(main!, second!)
                        second = nil
                    }
                }
            }
        } else if twoParameterOp.contains(symbol) {
            // do I need to calculate pending things?
            if second != nil && main != nil && opStack.count() > 0 {
                if let opName = opStack.pop() {
                    if let op = opDict[opName] {
                        main = op(main!, second!)
                        second = nil
                    }
                }
            } else {
                opStack.push(symbol)
                second = main
                main = nil
            }
        } else if inplaceOp.contains(symbol) {
            if let op = inplaceDict[symbol] {
                op(main!)
            }
        }
    }

    fileprivate var inplaceDict: Dictionary< String, (Gmp) -> () > = [
        "1\\x": rez
    ]

    fileprivate let twoParameterOp = Set(["+"])
    fileprivate let inplaceOp = Set(["1\\x"])

    fileprivate var opDict: Dictionary< String, (Gmp, Gmp) -> (Gmp) > = [
        "+": add
    ]

}
