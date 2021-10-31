//
//  OpStack.swift
//  Calculator
//
//  Created by Joachim Neumann on 23/09/2021.
//

import Foundation

class Operator: Equatable, Identifiable {
    let id = UUID()
    let priority: Int
    static let openParenthesesPriority = -2
    static let closedParenthesesPriority = -1
    static let equalPriority = -3
    init(_ priority: Int) {
        self.priority = priority
    }
    static func == (lhs: Operator, rhs: Operator) -> Bool {
        return lhs.id == rhs.id
    }
}



typealias inplaceType = (Gmp) -> () -> ()
typealias twoOperantsType = (Gmp) -> (Gmp) -> ()

class Inplace: Operator {
    let operation: inplaceType
    init(_ op: @escaping inplaceType, _ priority: Int) {
        operation = op
        super.init(priority)
    }
}

class TwoOperand: Operator {
    let operation: twoOperantsType
    init(_ op: @escaping twoOperantsType, _ priority: Int) {
        operation = op
        super.init(priority)
    }
}

struct OperatorStack: CustomDebugStringConvertible {
    private var array: [Operator] = []
    mutating func push(_ element: Operator) {
        array.append(element)
    }
    mutating func pop() -> Operator? {
        return array.popLast()
    }
    
    mutating func removeLast() {
        array.removeLast()
    }
    var hasOpenParentheses: Bool {
        for op in array {
             if op.priority == Operator.openParenthesesPriority { return true }
         }
         return false
    }
    var last: Operator? {
        array.last
    }
    var count: Int {
        array.count
    }
    var isEmpty: Bool { array.count == 0 }
    mutating func removeAll() {
        array.removeAll()
    }
    var debugDescription: String {
        let ret = "operatorStack: "
//        for toBePrinted in array {
//            for op in operators {
//                if op.value == toBePrinted {
//                    ret += ("op: \(op.key) priority: \(op.value.priority)\n")
//                }
//            }
//         }
        return ret
    }
}

