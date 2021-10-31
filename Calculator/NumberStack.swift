//
//  NumberStack.swift
//  Calculator
//
//  Created by Joachim Neumann on 29/09/2021.
//

import Foundation

struct NumberStack: CustomDebugStringConvertible{
    private var array: [Number] = []

    var count: Int {
        assert(array.count > 0)
        return array.count
    }
    var last: Number {
        assert(array.count > 0)
        return array.last!
    }

    mutating func replaceLast(with number: Number) {
        removeLast()
        append(number)
    }
    mutating func append(_ number: Number) {
        array.append(number)
    }
    mutating func popLast() -> Number {
        assert(array.count > 0)
        return array.popLast()!
    }
    mutating func removeLast() {
        assert(array.count > 0)
        array.removeLast()
    }
    mutating func removeAll() {
        array.removeAll()
    }
    
    var secondLast: Number? {
        if count >= 2 {
            return array[array.count - 2]
        } else {
            return nil
        }
    }
    
    var debugDescription: String {
        var ret = "numberStack \(array.count): "
        for number in array {
            ret += "\(number) "
        }
        return ret
    }
    
}
