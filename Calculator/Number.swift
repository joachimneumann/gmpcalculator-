//
//  Number.swift
//  Calculator
//
//  Created by Joachim Neumann on 10/26/21.
//

import Foundation

class Number: CustomDebugStringConvertible {
    private var _str: String?
    private var _gmp: Gmp?
    
    var isStr: Bool { _str != nil }
    var str: String? { return _str }
    var gmp: Gmp? { return _gmp }
    
    var isValid: Bool {
        if isStr { return true }
        return _gmp!.isValid
    }
    func copy() -> Number {
        if isStr {
            return Number(str!)
        } else {
            return Number(gmp!.copy())
        }
    }
    func toGmp() {
        if isStr {
            _gmp = Gmp(str!)
            _str = nil
        }
    }
    func execute(_ op: twoOperantsType, with other: Number) {
        toGmp()
        other.toGmp()
        _gmp!.execute(op, with: other._gmp!)
    }
    func execute(_ op: inplaceType) {
        toGmp()
        _gmp!.inPlace(op: op)
    }
    
    init(_ str: String) {
        _str = str
        _gmp = nil
    }
    init(_ gmp: Gmp) {
        _str = nil
        _gmp = gmp
    }
    convenience init() {
        self.init("0")
    }
    
    func addZero()  {
        if isStr {
            if _str != "0" {
                _str!.append("0")
            }
        } else {
            _str = "0"
            _gmp = nil
        }
    }
    
    func addComma() {
        if str == nil {
            _str = "0,"
        } else {
            if !_str!.contains(",") { _str!.append(",") }
        }
    }
    
    func addDigit(_ digit: String) {
        if !isStr || _str == "0" {
            _str = digit
        } else {
            _str!.append(digit)
        }
    }
    
    func changeSign() {
        if isStr {
            if _str == "0" { return }
            if _str!.starts(with: "-") {
                _str!.removeFirst()
            } else {
                _str! = "-" + _str!
            }
        } else {
            _gmp!.changeSign()
        }
    }
    var debugDescription: String {
        if isStr {
            return "\(_str!) s "
        } else {
            return "\(_gmp!.toDouble()) g "
        }
    }
}
