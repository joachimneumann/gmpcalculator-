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
    
    let counter: CUnsignedLong = mpfr_get_ui(&exponent.mpfr, MPFR_RNDN) - 1
    for _ in 0 ... counter {
        mpfr_pow(&base.mpfr, &left, &base.mpfr, MPFR_RNDN)
    }
    mpfr_clear(&left)
    return base
}

func changeSign(left: Gmp) -> Gmp {
    mpfr_neg(&left.mpfr, &left.mpfr, MPFR_RNDN)
    return left
}

func π(left: Gmp) -> Gmp {
    mpfr_const_pi(&left.mpfr, MPFR_RNDN)
    return left
}
func sqrt(left: Gmp) -> Gmp {
    mpfr_sqrt(&left.mpfr, &left.mpfr, MPFR_RNDN)
    return left
}
func sqrt3(left: Gmp) -> Gmp {
    mpfr_cbrt(&left.mpfr, &left.mpfr, MPFR_RNDN)
    return left
}
func rez(left: Gmp) -> Gmp {
    mpfr_ui_div(&left.mpfr, 1, &left.mpfr, MPFR_RNDN)
    return left
}
func fac(left: Gmp) -> Gmp {
    let n = mpfr_get_si(&left.mpfr, MPFR_RNDN)
    if n >= 0 {
        let un = UInt(n)
        mpfr_fac_ui(&left.mpfr, un, MPFR_RNDN)
    } else {
        mpfr_set_d(&left.mpfr, 0.0, MPFR_RNDN)
    }
    return left
}
func ln(left: Gmp) -> Gmp {
    mpfr_log(&left.mpfr, &left.mpfr, MPFR_RNDN)
    return left
}
func log10(left: Gmp) -> Gmp {
    mpfr_log10(&left.mpfr, &left.mpfr, MPFR_RNDN)
    return left
}
func sin(left: Gmp) -> Gmp {
    mpfr_sin(&left.mpfr, &left.mpfr, MPFR_RNDN)
    return left
}
func cos(left: Gmp) -> Gmp {
    mpfr_cos(&left.mpfr, &left.mpfr, MPFR_RNDN)
    return left
}
func tan(left: Gmp) -> Gmp {
    mpfr_tan(&left.mpfr, &left.mpfr, MPFR_RNDN)
    return left
}
func e(left: Gmp) -> Gmp {
    var one: mpfr_t = mpfr_t(_mpfr_prec: 0, _mpfr_sign: 0, _mpfr_exp: 0, _mpfr_d: &dummyUnsignedLongInt)
    mpfr_init2 (&one, mpfr_get_prec(&left.mpfr))
    mpfr_set_d(&one, 1.0, MPFR_RNDN)
    mpfr_exp(&left.mpfr, &one, MPFR_RNDN); // Strangely, this returns a status of -1
    mpfr_clear(&one);
    return left
}
func γ(left: Gmp) -> Gmp {
    mpfr_const_euler(&left.mpfr, MPFR_RNDN)
    return left
}
func pow_x_2(left: Gmp) -> Gmp {
    mpfr_sqr(&left.mpfr, &left.mpfr, MPFR_RNDN)
    return left
}
func pow_x_3(left: Gmp) -> Gmp {
    mpfr_pow_ui(&left.mpfr, &left.mpfr, 3, MPFR_RNDN)
    return left
}
func pow_e_x(left: Gmp) -> Gmp {
    mpfr_exp(&left.mpfr, &left.mpfr, MPFR_RNDN)
    return left
}
func pow_10_x(left: Gmp) -> Gmp {
    mpfr_exp10(&left.mpfr, &left.mpfr, MPFR_RNDN)
    return left
}

class Gmp {
    // Swift wants me to initialize the mpfr_t struc
    // I do this will zeros. The struct will be initialized with correct values in mpfr_init2
    private var mpfr: mpfr_t = mpfr_t(_mpfr_prec: 0, _mpfr_sign: 0, _mpfr_exp: 0, _mpfr_d: &dummyUnsignedLongInt)
    
    init(_ d: Double, precision: CLong) {
        mpfr_init2 (&mpfr, precision)
        mpfr_set_d (&mpfr, d, MPFR_RNDN)
    }
    convenience init(_ s: String, precision: CLong) {
        let scientific = s.stringByReplacingOccurrencesOfString(" E", withString: "E")
        let decimalNumber = NSDecimalNumber(string: scientific)
        
        if decimalNumber == NSDecimalNumber.notANumber() {
            self.init(0.0, precision: precision)
        } else {
            self.init(decimalNumber.doubleValue, precision: precision)
        }
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
        
        if s1.characters.first == "-" {
            s1.insert(".", atIndex: s1.startIndex.advancedBy(2))
        } else {
            s1.insert(".", atIndex: s1.startIndex.advancedBy(1))
        }
        s1 += "e"+String(expptr-1)

        return s1
    }

    func isNull() -> Bool {
        return mpfr_cmp_d(&mpfr, 0.0) == 0
    }

    func isNegtive() -> Bool {
        return mpfr_cmp_d(&mpfr, 0.0) < 0
    }
}
