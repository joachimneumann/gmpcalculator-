//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Joachim Neumann on 09/05/2016.
//  Copyright © 2016 VISAMED IT. All rights reserved.
//

import Foundation

private var internalProgram = [AnyObject]()

class CalculatorBrain {
    
    init() {
        accumulator = Gmp(0.0, precision: nBits)
    }
    private var accumulator: Gmp

    // we start with the IEEE double spec
    var nBits: Int = 53 {
        didSet {
            reset()
        }
    }
    
    var isPending: Bool = false
    
    func setOperand(operand: Gmp) {
        internalProgram.append(operand)
        accumulator = operand
    }
    
    func reset() {
        internalProgram.removeAll()
        accumulator = Gmp(0.0, precision: nBits)
        isPending = false
    }
    
    typealias PropertyList = AnyObject
    var program: PropertyList {
        get {
            return internalProgram
        }
        set {
            reset()
            // Do I need to test if newValue =!= nil ???
            if let steps = newValue as? [AnyObject] {
                for step in steps {
                    if let d = step as? Gmp {
                        setOperand((d))
                    }
                    if let op = step as? String {
                        performOperation(op)
                    }
                }
            }
        }
    }
    

    
    private var operations: Dictionary<String, Operation> = [
        "C": Operation.Reset,
        "±": Operation.UnaryOperation(changeSign),
        "π": Operation.UnaryOperation(π),
        "e": Operation.UnaryOperation(e),
        "γ": Operation.UnaryOperation(γ),
        "1/x": Operation.UnaryOperation(rez),
        "x!": Operation.UnaryOperation(fac),
        "ln": Operation.UnaryOperation(ln),
        "log10": Operation.UnaryOperation(log10),
        "√": Operation.UnaryOperation(sqrt),
        "3√": Operation.UnaryOperation(sqrt3),
        "sin": Operation.UnaryOperation(sin),
        "cos": Operation.UnaryOperation(cos),
        "tan": Operation.UnaryOperation(tan),
        "x^2": Operation.UnaryOperation(pow_x_2),
        "x^3": Operation.UnaryOperation(pow_x_3),
        "e^x": Operation.UnaryOperation(pow_e_x),
        "10^x": Operation.UnaryOperation(pow_10_x),
        "×": Operation.BinaryOperation(*),
        "+": Operation.BinaryOperation(+),
        "−": Operation.BinaryOperation(-),
        "÷": Operation.BinaryOperation(/),
        "x^y": Operation.BinaryOperation(pow_x_y),
        "x↑↑y": Operation.BinaryOperation(x_double_up_arrow_y),
        "=": Operation.Equals
    ]
    
    private enum Operation {
        case Constant(Gmp)
        case UnaryOperation((Gmp) -> Gmp)
        case BinaryOperation((Gmp, Gmp) -> (Gmp))
        case Equals
        case Reset
    }
    
    var description: String = ""/*{
        get {
            var s = ""
            for step in internalProgram {
                if let d = step as? Gmp {
                    s += d.toString(DisplayMode.simple)
                }
                if let op = step as? String {
                    s += op
                }
            }
            return s
        }
    }*/

    func performOperation(symbol: String) {
        internalProgram.append(symbol)
        if let operation = operations[symbol] {
            switch operation {
            case .Constant(let value):
                accumulator = value
                isPending = false
            case .UnaryOperation(let f):
                accumulator = f(accumulator)
                isPending = false
            case .BinaryOperation(let f):
                if (pending != nil) {
                    executePendingOperation()
                }
                pending = PendingBinaryOperationInfo(binaryFunction: f, firstOperand: accumulator)
                isPending = true // isPending is set false in executePendingOperation
            case .Equals:
                if (pending != nil) {
                    executePendingOperation()
                } else {
                    // there was no operation pending, delete the program
                    internalProgram.removeAll()
                    internalProgram.append(result)
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