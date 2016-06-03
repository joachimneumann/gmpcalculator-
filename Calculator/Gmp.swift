//
//  Gmp.swift
//  Calculator
//
//  Created by Joachim Neumann on 24/05/16.
//  Copyright © 2016 VISAMED IT. All rights reserved.
//


// This class bridges between swift and the GMP library that is implemented in C


import Foundation

var dummyUnsignedLongInt: CUnsignedLong = 0

func + (left: Gmp, right: Gmp) -> Gmp {
    mpfr_add(&left.mpfr, &left.mpfr, &right.mpfr, MPFR_RNDN)
    return left
}

func / (left: Gmp, right: Gmp) -> Gmp {
    mpfr_div(&left.mpfr, &left.mpfr, &right.mpfr, MPFR_RNDN)
    return left
}

func - (left: Gmp, right: Gmp) -> Gmp {
    mpfr_sub(&left.mpfr, &left.mpfr, &right.mpfr, MPFR_RNDN)
    return left
}
func * (left: Gmp, right: Gmp) -> Gmp {
    mpfr_mul(&left.mpfr, &left.mpfr, &right.mpfr, MPFR_RNDN)
    return left
}

func pow_x_y(base: Gmp, exponent: Gmp) -> Gmp {
    mpfr_pow(&base.mpfr, &base.mpfr, &exponent.mpfr, MPFR_RNDN)
    return base
}
func x_double_up_arrow_y(base: Gmp, exponent: Gmp) -> Gmp {
    var left: mpfr_t = mpfr_t(_mpfr_prec: 0, _mpfr_sign: 0, _mpfr_exp: 0, _mpfr_d: &dummyUnsignedLongInt)
    mpfr_init2 (&left, mpfr_get_prec(&base.mpfr))
    mpfr_set(&left, &base.mpfr, MPFR_RNDN)
    
    let counter: CLong = mpfr_get_si(&exponent.mpfr, MPFR_RNDN) - 1
    guard counter > 0 else { return base }
    for _ in 0..<counter {
        mpfr_pow(&base.mpfr, &left, &base.mpfr, MPFR_RNDN)
    }
    mpfr_clear(&left)
    return base
}

func changeSign(left: Gmp) {
    mpfr_neg(&left.mpfr, &left.mpfr, MPFR_RNDN)
}

func π(left: Gmp) {
    mpfr_const_pi(&left.mpfr, MPFR_RNDN)
}
func sqrt(left: Gmp) {
    mpfr_sqrt(&left.mpfr, &left.mpfr, MPFR_RNDN)
}
func sqrt3(left: Gmp) {
    mpfr_cbrt(&left.mpfr, &left.mpfr, MPFR_RNDN)
}
func rez(left: Gmp) {
    mpfr_ui_div(&left.mpfr, 1, &left.mpfr, MPFR_RNDN)
}
func fac(left: Gmp) {
    let n = mpfr_get_si(&left.mpfr, MPFR_RNDN)
    if n >= 0 {
        let un = UInt(n)
        mpfr_fac_ui(&left.mpfr, un, MPFR_RNDN)
    } else {
        mpfr_set_d(&left.mpfr, 0.0, MPFR_RNDN)
    }
}
func ln(left: Gmp) {
    mpfr_log(&left.mpfr, &left.mpfr, MPFR_RNDN)
}
func log10(left: Gmp) {
    mpfr_log10(&left.mpfr, &left.mpfr, MPFR_RNDN)
}
func sin(left: Gmp) {
    mpfr_sin(&left.mpfr, &left.mpfr, MPFR_RNDN)
}
func cos(left: Gmp) {
    mpfr_cos(&left.mpfr, &left.mpfr, MPFR_RNDN)
}
func tan(left: Gmp) {
    mpfr_tan(&left.mpfr, &left.mpfr, MPFR_RNDN)
}
func e(left: Gmp) {
    var one: mpfr_t = mpfr_t(_mpfr_prec: 0, _mpfr_sign: 0, _mpfr_exp: 0, _mpfr_d: &dummyUnsignedLongInt)
    mpfr_init2 (&one, mpfr_get_prec(&left.mpfr))
    mpfr_set_d(&one, 1.0, MPFR_RNDN)
    mpfr_exp(&left.mpfr, &one, MPFR_RNDN); // Strangely, this returns a status of -1
    mpfr_clear(&one);
}
func γ(left: Gmp) {
    mpfr_const_euler(&left.mpfr, MPFR_RNDN)
}
func pow_x_2(left: Gmp) {
    mpfr_sqr(&left.mpfr, &left.mpfr, MPFR_RNDN)
}
func pow_x_3(left: Gmp) {
    mpfr_pow_ui(&left.mpfr, &left.mpfr, 3, MPFR_RNDN)
}
func pow_e_x(left: Gmp) {
    mpfr_exp(&left.mpfr, &left.mpfr, MPFR_RNDN)
}
func pow_10_x(left: Gmp) {
    mpfr_exp10(&left.mpfr, &left.mpfr, MPFR_RNDN)
}

class Gmp {
    // Swift requires me to initialize the mpfr_t struc
    // I do this will zeros. The struct will be initialized correctly in mpfr_init2
    private var mpfr: mpfr_t = mpfr_t(_mpfr_prec: 0, _mpfr_sign: 0, _mpfr_exp: 0, _mpfr_d: &dummyUnsignedLongInt)
    
    // there is only ine initialzer that takes a string.
    // Implementing an initializer that accepts a double which is created from a string leads to a loss of precision.
    init(_ s: String, precision: CLong) {
        mpfr_init2 (&mpfr, precision)
        mpfr_set_str (&mpfr, s, 10, MPFR_RNDN)
    }
    

    func setPrecisionTo(nBits: CLong) {
        mpfr_set_prec (&mpfr, nBits)
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
        var charArray: Array<CChar> = Array(count: significantBytesEstimate+10, repeatedValue: 32) // plus 10 just to be safe because I am lazy
        mpfr_get_str(&charArray, &expptr, 10, significantBytesEstimate, &mpfr, MPFR_RNDN)
        
        guard var s1 = String.fromCString(charArray)
            else { return "can not converted to string" }

        while s1.characters.last == "0" {
            s1 = String(s1.characters.dropLast())
        }

        // make sure, the string is at least 2 characters long
        while s1.characters.count < 2 {
            s1 += "0"
        }
        
        // do we have a simple doule that can written in decimal notation?
        let doubleDigits = s1.characters.first == "-" ? 7:6
        if s1.characters.count < doubleDigits && abs(expptr) < 10 {
            let d = mpfr_get_d(&mpfr, MPFR_RNDN)
            return String(d)
        }
        
        if s1.characters.first == "-" {
            s1.insert(".", atIndex: s1.startIndex.advancedBy(2))
        } else {
            s1.insert(".", atIndex: s1.startIndex.advancedBy(1))
        }
        
        // if exponent is 0, drop it
        if expptr-1 != 0 {
            s1 += "e"+String(expptr-1)
        }

        return s1
    }

    func isNull() -> Bool {
        return mpfr_cmp_d(&mpfr, 0.0) == 0
    }

    func isNegtive() -> Bool {
        return mpfr_cmp_d(&mpfr, 0.0) < 0
    }
}
