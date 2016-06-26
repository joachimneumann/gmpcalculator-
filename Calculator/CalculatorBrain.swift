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
    private var accumulator: Gmp
    private var nBits = 250
    var digits: Int {
        set {
            nBits = Int(round(Double(newValue) / 0.3))
            accumulator.setPrecisionTo(nBits)
        }
        get {
            return Int(round(Double(nBits) * 0.3))
        }
    }
    
    var isPending: Bool = false
    
    func newDigit(digit: String) {
        internalProgram.append(digit)
    }
    
    func setDigit(digit: String) {
        internalProgram.removeLast()
        newDigit(digit)
    }
    
    func setOperand(operand: String) {
        internalProgram.append(operand)
        let value = Gmp(operand, precision: nBits)
        setOperand(value)
    }

    private func setOperand(operand: Gmp) {
        accumulator = operand
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
            return internalProgram
        }
//        set {
//            reset()
//            // Do I need to test if newValue =!= nil ???
//            if let steps = newValue as? [AnyObject] {
//                for step in steps {
//                    if let d = step as? Gmp {
//                        setOperand((d))
//                    }
//                    if let op = step as? String {
//                        performOperation(op)
//                    }
//                }
//            }
//        }
    }
    

    
    private var operations: Dictionary<String, Operation> = [
        "C": Operation.Reset,
        "±": Operation.InPlaceOperation(changeSign),
        "π": Operation.InPlaceOperation(π),
        "e": Operation.InPlaceOperation(e),
        "γ": Operation.InPlaceOperation(γ),
        "1/x": Operation.InPlaceOperation(rez),
        "x!": Operation.InPlaceOperation(fac),
        "ln": Operation.InPlaceOperation(ln),
        "log10": Operation.InPlaceOperation(log10),
        "√": Operation.InPlaceOperation(sqrt),
        "3√": Operation.InPlaceOperation(sqrt3),
        "sin": Operation.InPlaceOperation(sin),
        "cos": Operation.InPlaceOperation(cos),
        "tan": Operation.InPlaceOperation(tan),
        "x^2": Operation.InPlaceOperation(pow_x_2),
        "x^3": Operation.InPlaceOperation(pow_x_3),
        "e^x": Operation.InPlaceOperation(pow_e_x),
        "10^x": Operation.InPlaceOperation(pow_10_x),
        "×": Operation.BinaryOperation(*),
        "+": Operation.BinaryOperation(+),
        "−": Operation.BinaryOperation(-),
        "÷": Operation.BinaryOperation(/),
        "x^y": Operation.BinaryOperation(pow_x_y),
        "x↑↑y": Operation.BinaryOperation(x_double_up_arrow_y),
        "=": Operation.Equals
    ]
    
    private enum Operation {
        case InPlaceOperation((Gmp) -> ())
        case BinaryOperation((Gmp, Gmp) -> (Gmp))
        case Equals
        case Reset
    }
    
    var programDescription: String {
        get {
            return internalProgram.joinWithSeparator(" ")
        }
    }

    func performOperation(symbol: String) {
        internalProgram.append(symbol)
        if let operation = operations[symbol] {
            switch operation {
            case .InPlaceOperation(let f):
                f(accumulator)
                isPending = false
            case .BinaryOperation(let f):
                if (pending != nil) {
                    executePendingOperation()
                }
                pending = PendingBinaryOperationInfo(binaryFunction: f, firstOperand: accumulator.copy())
                isPending = true // isPending is set false in executePendingOperation
            case .Equals:
                if (pending != nil) {
                    executePendingOperation()
                } else {
                    // there was no operation pending, delete the program
                    internalProgram.removeAll()
                }
            case .Reset:
                reset()
            }
        }
    }

    private func executePendingOperation() {
        accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
        pending = nil;
        isPending = false
    }
    
    private var pending: PendingBinaryOperationInfo?

    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Gmp, Gmp) -> (Gmp)
        var firstOperand: Gmp
    }
    
    var result: Gmp {
        get {
            return accumulator
        }
    }
}
