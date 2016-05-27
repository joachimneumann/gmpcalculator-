//
//  Gmp.swift
//  Calculator
//
//  Created by Joachim Neumann on 24/05/16.
//  Copyright © 2016 VISAMED IT. All rights reserved.
//

import Foundation

func + (left: Gmp, right: Gmp) -> Gmp {
    left.d.add(right.d)
    return left
}
func / (left: Gmp, right: Gmp) -> Gmp {
    left.d.div(right.d)
    return left
}
func - (left: Gmp, right: Gmp) -> Gmp {
    left.d.sub(right.d)
    return left
}
func * (left: Gmp, right: Gmp) -> Gmp {
    left.d.mul(right.d)
    return left
}
func sqrt(left: Gmp) -> Gmp {
    left.d.sqrt()
    return left
}
func sqrt3(left: Gmp) -> Gmp {
    left.d.sqrt3()
    return left
}
func rez(left: Gmp) -> Gmp {
    left.d.rez()
    return left
}
func fac(left: Gmp) -> Gmp {
    left.d.fac()
    return left
}
func ln(left: Gmp) -> Gmp {
    left.d.ln()
    return left
}
func log10(left: Gmp) -> Gmp {
    left.d.log10()
    return left
}
func sin(left: Gmp) -> Gmp {
    left.d.sin()
    return left
}
func cos(left: Gmp) -> Gmp {
    left.d.cos()
    return left
}
func tan(left: Gmp) -> Gmp {
    left.d.tan()
    return left
}
func changeSign(left: Gmp) -> Gmp {
    left.d.changeSign()
    return left
}
func π(left: Gmp) -> Gmp {
    left.d.π()
    return left
}
func e(left: Gmp) -> Gmp {
    left.d.e()
    return left
}
func γ(left: Gmp) -> Gmp {
    left.d.γ()
    return left
}
func pow_x_2(left: Gmp) -> Gmp {
    left.d.pow_x_2()
    return left
}
func pow_x_3(left: Gmp) -> Gmp {
    left.d.pow_x_3()
    return left
}
func pow_e_x(left: Gmp) -> Gmp {
    left.d.pow_e_x()
    return left
}
func pow_10_x(left: Gmp) -> Gmp {
    left.d.pow_10_x()
    return left
}
func pow_x_y(base: Gmp, exponent: Gmp) -> Gmp {
    base.d.pow_x_y(exponent.d)
    return base
}
func x_double_up_arrow_y(base: Gmp, exponent: Gmp) -> Gmp {
    base.d.x_double_up_arrow_y(exponent.d)
    return base
}


class Gmp {
    private var d: GmpObjC
    
    init (_ dd: Double, precision: CLong) {
        d = GmpObjC(double: dd, andPrecision: precision)
    }
    init (_ dd: String, precision: CLong) {
        let scientific = dd.stringByReplacingOccurrencesOfString(" E", withString: "E")
        let decimalNumber = NSDecimalNumber(string: scientific)
        
        if decimalNumber == NSDecimalNumber.notANumber() {
            d = GmpObjC(double:0, andPrecision: precision)
        } else {
            d = GmpObjC(double:decimalNumber.doubleValue, andPrecision: precision)
        }
    }
    
    func setPrecisionTo(nBits: CLong) {
        d.setPrecisionTo(nBits)
    }

    func toString() -> String {
        return d.toString()
    }

    func isNull() -> Bool {
        if d.isNull() {
            return true
        } else {
            return false
        }
    }
    func isNegtive() -> Bool {
        if d.isNegative() {
            return true
        } else {
            return false
        }
    }
}
