//
//  Gmp.swift
//  Calculator
//
//  Created by Joachim Neumann on 24/05/16.
//  Copyright © 2016 mindo software S.L. All rights reserved.
//


// This class bridges between swift and the GMP library that is implemented in C


import Foundation


extension String {
    
    subscript (i: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
}

var dummyUnsignedLongInt: CUnsignedLong = 0

func + (left: Gmp, right: Gmp) -> Gmp {
    mpfr_add(&left.mpfr, &left.copy().mpfr, &right.mpfr, MPFR_RNDN)
    return left
}

func / (left: Gmp, right: Gmp) -> Gmp {
    mpfr_div(&left.mpfr, &left.copy().mpfr, &right.mpfr, MPFR_RNDN)
    return left
}

func - (left: Gmp, right: Gmp) -> Gmp {
    mpfr_sub(&left.mpfr, &left.copy().mpfr, &right.mpfr, MPFR_RNDN)
    return left
}
func * (left: Gmp, right: Gmp) -> Gmp {
    mpfr_mul(&left.mpfr, &left.copy().mpfr, &right.mpfr, MPFR_RNDN)
    return left
}

func pow_x_y(_ base: Gmp, exponent: Gmp) -> Gmp {
    mpfr_pow(&base.mpfr, &base.copy().mpfr, &exponent.mpfr, MPFR_RNDN)
    return base
}
func x_double_up_arrow_y(_ left: Gmp, right: Gmp) -> Gmp {
    var temp: mpfr_t = mpfr_t(_mpfr_prec: 0, _mpfr_sign: 0, _mpfr_exp: 0, _mpfr_d: &dummyUnsignedLongInt)
    mpfr_init2 (&temp, mpfr_get_prec(&left.mpfr))
    mpfr_set(&temp, &left.mpfr, MPFR_RNDN)
    
    let counter: CLong = mpfr_get_si(&right.mpfr, MPFR_RNDN) - 1
    guard counter > 0 else { return left }
    for _ in 0..<counter {
        mpfr_pow(&left.mpfr, &temp, &left.copy().mpfr, MPFR_RNDN)
    }
    mpfr_clear(&temp)
    return left
}

func changeSign(_ me: Gmp) {
    mpfr_neg(&me.mpfr, &me.copy().mpfr, MPFR_RNDN)
}

func π(_ me: Gmp) {
    mpfr_const_pi(&me.mpfr, MPFR_RNDN)
}
func sqrt(_ me: Gmp) {
    mpfr_sqrt(&me.mpfr, &me.copy().mpfr, MPFR_RNDN)
}
func sqrt3(_ me: Gmp) {
    mpfr_cbrt(&me.mpfr, &me.copy().mpfr, MPFR_RNDN)
}
func rez(_ me: Gmp) {
    mpfr_ui_div(&me.mpfr, 1, &me.copy().mpfr, MPFR_RNDN)
}
func fac(_ me: Gmp) {
    let n = mpfr_get_si(&me.mpfr, MPFR_RNDN)
    if n >= 0 {
        let un = UInt(n)
        mpfr_fac_ui(&me.mpfr, un, MPFR_RNDN)
    } else {
        mpfr_set_d(&me.mpfr, 0.0, MPFR_RNDN)
    }
}
func ln(_ me: Gmp) {
    mpfr_log(&me.mpfr, &me.copy().mpfr, MPFR_RNDN)
}
func log10(_ me: Gmp) {
    mpfr_log10(&me.mpfr, &me.copy().mpfr, MPFR_RNDN)
}
func sin(_ me: Gmp) {
    mpfr_sin(&me.mpfr, &me.copy().mpfr, MPFR_RNDN)
}
func cos(_ me: Gmp) {
    mpfr_cos(&me.mpfr, &me.copy().mpfr, MPFR_RNDN)
}
func tan(_ me: Gmp) {
    mpfr_tan(&me.mpfr, &me.copy().mpfr, MPFR_RNDN)
}
func e(_ me: Gmp) {
    var one: mpfr_t = mpfr_t(_mpfr_prec: 0, _mpfr_sign: 0, _mpfr_exp: 0, _mpfr_d: &dummyUnsignedLongInt)
    mpfr_init2 (&one, mpfr_get_prec(&me.mpfr))
    mpfr_set_d(&one, 1.0, MPFR_RNDN)
    mpfr_exp(&me.mpfr, &one, MPFR_RNDN); // Strangely, this returns a status of -1
    mpfr_clear(&one);
}
func γ(_ me: Gmp) {
    mpfr_const_euler(&me.mpfr, MPFR_RNDN)
}
func pow_x_2(_ me: Gmp) {
    mpfr_sqr(&me.mpfr, &me.copy().mpfr, MPFR_RNDN)
}
func pow_x_3(_ me: Gmp) {
    mpfr_pow_ui(&me.mpfr, &me.copy().mpfr, 3, MPFR_RNDN)
}
func pow_e_x(_ me: Gmp) {
    mpfr_exp(&me.mpfr, &me.copy().mpfr, MPFR_RNDN)
}
func pow_10_x(_ me: Gmp) {
    mpfr_exp10(&me.mpfr, &me.copy().mpfr, MPFR_RNDN)
}

class Gmp {
    // Swift requires me to initialize the mpfr_t struc
    // I do this will zeros. The struct will be initialized correctly in mpfr_init2
    fileprivate var mpfr: mpfr_t = mpfr_t(_mpfr_prec: 0, _mpfr_sign: 0, _mpfr_exp: 0, _mpfr_d: &dummyUnsignedLongInt)
    
    // there is only ine initialzer that takes a string.
    // Implementing an initializer that accepts a double which is created from a string leads to a loss of precision.
    init(_ s: String, precision: CLong) {
        let s1 = s.replacingOccurrences(of: " E", with: "e")
        mpfr_init2 (&mpfr, precision)
        mpfr_set_str (&mpfr, s1, 10, MPFR_RNDN)
    }

    func copy() -> Gmp {
        let ret = Gmp("0.0", precision: mpfr_get_prec(&mpfr))
        mpfr_set(&ret.mpfr, &mpfr, MPFR_RNDN)
        return ret
    }
    
    func setPrecisionTo(_ nBits: CLong) {
        // mpfr_set_prec sets the value to NaN, but we want to preserve the value
        
        var temp: mpfr_t = mpfr_t(_mpfr_prec: 0, _mpfr_sign: 0, _mpfr_exp: 0, _mpfr_d: &dummyUnsignedLongInt)
        mpfr_init2 (&temp, nBits)
        mpfr_set(&temp, &mpfr, MPFR_RNDN)
        
        mpfr_set_prec (&mpfr, nBits)
        
        mpfr_set(&mpfr, &temp, MPFR_RNDN)
        
        mpfr_clear(&temp)
    }

    
    func toString() -> String {
        if mpfr_nan_p(&mpfr) != 0 {
            return "Not a Number"
        }
        if mpfr_inf_p(&mpfr) != 0 {
            return "Infinity"
        }
        
        // set negative 0 to 0
        if mpfr_zero_p(&mpfr) != 0 {
            return "0"
        }

        
        let significantBytesEstimate = Int(round(0.3 * Double(mpfr_get_prec(&mpfr))))
        var expptr: mpfr_exp_t = 0
        var charArray: Array<CChar> = Array(repeating: 0, count: significantBytesEstimate+2) // +2 because: one for a possible - and one for zero termination
        mpfr_get_str(&charArray, &expptr, 10, significantBytesEstimate, &mpfr, MPFR_RNDN)
        
        // for speed, we work a bit with the charArray before using swift string
        
        // negative?
        var negative = false
        if charArray[0] == 45 {
            charArray.removeFirst()
            negative = true
        }
        
        // find last significant digit
        var lastSignificantIndex = charArray.count-1
        while (charArray[lastSignificantIndex] == 0 || charArray[lastSignificantIndex] == 48) && lastSignificantIndex > 0 { lastSignificantIndex -= 1 }
        let lastSignificantDigit = lastSignificantIndex + 1
        
        // is it an Integer?
        if expptr > 0 && lastSignificantDigit <= expptr && expptr < significantBytesEstimate {
            charArray[expptr] = 0
            guard let integerString = String(validatingUTF8: charArray)
                else { return "not a number" }
            if negative {
                return "-"+integerString
            } else {
                return integerString
            }
        }
        
        // do we have a simple double that can written in decimal notation?
        let doubleDigits = 6
        if lastSignificantDigit < doubleDigits && abs(expptr) < 10 {
            let d = mpfr_get_d(&mpfr, MPFR_RNDN)
            return String(d)
        }

        charArray[lastSignificantDigit] = 0

        guard var floatString = String(validatingUTF8: charArray)
            else { return "not a number" }
        
        // make sure the lenfth of the float string is at least two characters
        while floatString.count < 2 { floatString += "0" }
        
        floatString.insert(".", at: floatString.index(floatString.startIndex, offsetBy: 1))
        
        // if exponent is 0, drop it
        if expptr-1 != 0 {
            floatString += " E"+String(expptr-1)
        }

        if negative {
            return "-"+floatString
        } else {
            return floatString
        }
    }

    func isNull() -> Bool {
        return mpfr_cmp_d(&mpfr, 0.0) == 0
    }

    func isNegtive() -> Bool {
        return mpfr_cmp_d(&mpfr, 0.0) < 0
    }
}
