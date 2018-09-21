//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Joachim Neumann on 09/05/2016.
//  Copyright © 2016 mindo software S.L. All rights reserved.
//

import Foundation

private var internalProgram = [String]()

class CalculatorBrain {
    
    init() {
        accumulator = Gmp("0.0", precision: nBits)
    }
    fileprivate var accumulator: Gmp
    fileprivate var nBits = 250
    var precision: Int {
        set {
            nBits = Int(round(Double(newValue) / 0.3))
            accumulator.setPrecisionTo(nBits)
        }
        get {
            return Int(round(Double(nBits) * 0.3))
        }
    }
    
    var isPending: Bool = false
    
    func newDigit(_ digit: String) {
        internalProgram.append(digit)
    }
    
    func setDigit(_ digit: String) {
        internalProgram.removeLast()
        newDigit(digit)
    }
    
    func setOperand(_ operand: String) {
        internalProgram.append(operand)
        setAccumulator(Gmp(operand, precision: nBits))
    }

    fileprivate func setAccumulator(_ accu: Gmp) {
        accumulator = accu
    }
    
    func reset() {
        internalProgram.removeAll()
        accumulator = Gmp("0.0", precision: nBits)
        pending = nil;
        isPending = false
    }
    
    typealias PropertyList = AnyObject
    
    var program: PropertyList {
        get {
            return internalProgram as CalculatorBrain.PropertyList
        }
    }

    
    fileprivate var operations: Dictionary<String, Operation> = [
        "C": Operation.reset,
        "±": Operation.inPlaceOperation(changeSign),
        "π": Operation.inPlaceOperation(π),
        "e": Operation.inPlaceOperation(e),
        "γ": Operation.inPlaceOperation(γ),
        "1\\x": Operation.inPlaceOperation(rez),
        "x!": Operation.inPlaceOperation(fac),
        "ln": Operation.inPlaceOperation(ln),
        "log10": Operation.inPlaceOperation(log10),
        "√": Operation.inPlaceOperation(sqrt),
        "3√": Operation.inPlaceOperation(sqrt3),
        "sin": Operation.inPlaceOperation(sin),
        "cos": Operation.inPlaceOperation(cos),
        "tan": Operation.inPlaceOperation(tan),
        "x^2": Operation.inPlaceOperation(pow_x_2),
        "x^3": Operation.inPlaceOperation(pow_x_3),
        "e^x": Operation.inPlaceOperation(pow_e_x),
        "10^x": Operation.inPlaceOperation(pow_10_x),
        "×": Operation.binaryOperation(*),
        "+": Operation.binaryOperation(+),
        "−": Operation.binaryOperation(-),
        "÷": Operation.binaryOperation(/),
        "x^y": Operation.binaryOperation(pow_x_y),
        "x↑↑y": Operation.binaryOperation(x_double_up_arrow_y),
        "=": Operation.equals
    ]
    
    fileprivate enum Operation {
        case inPlaceOperation((Gmp) -> ())
        case binaryOperation((Gmp, Gmp) -> (Gmp))
        case equals
        case reset
    }
    
    var programDescription: String {
        get {
            return internalProgram.joined(separator: " ")
        }
    }

    func performOperation(_ symbol: String) {
        internalProgram.append(symbol)
        if let operation = operations[symbol] {
            switch operation {
            case .inPlaceOperation(let f):
                f(accumulator)
                isPending = false
            case .binaryOperation(let f):
                if (pending != nil) {
                    executePendingOperation()
                }
                pending = PendingBinaryOperationInfo(binaryFunction: f, firstOperand: accumulator.copy())
                isPending = true // isPending is set false in executePendingOperation
            case .equals:
                if (pending != nil) {
                    executePendingOperation()
                } else {
                    // there was no operation pending, delete the program
                    internalProgram.removeAll()
                }
            case .reset:
                reset()
            }
        }
    }

    fileprivate func executePendingOperation() {
        let temp = pending!.binaryFunction(pending!.firstOperand, accumulator)
        accumulator = temp
        pending = nil;
        isPending = false
    }
    
    fileprivate var pending: PendingBinaryOperationInfo?

    fileprivate struct PendingBinaryOperationInfo {
        var binaryFunction: (Gmp, Gmp) -> (Gmp)
        var firstOperand: Gmp
    }
    
    var result: Gmp {
        get {
            return accumulator
        }
    }
}
