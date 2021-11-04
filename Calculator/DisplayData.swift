//
//  DisplayData.swift
//  Calculator
//
//  Created by Joachim Neumann on 24/09/2021.
//

import SwiftUI


class DisplayData: ObservableObject {
    @Published var nonScientific: String?
    @Published var scientific: Scientific?

    static let digitsInExpandedDisplay: Int = 200
    static var digitsInOneLine: Int = 0

    struct Scientific: Equatable {
        let mantissa: String
        let exponent: String
        
        var combined: String { mantissa + " " + exponent }
        init(_ mantissa: String, _ exponent: String) {
            self.mantissa = mantissa
            self.exponent = exponent
        }
        
        static func == (lhs: Scientific, rhs: Scientific) -> Bool {
            if lhs.mantissa != rhs.mantissa { return false }
            if lhs.exponent != rhs.exponent { return false }
            return true
        }
    }

    init() {
        self.nonScientific = "invalid"
        self.scientific = nil
    }
    private func set(_ ns: String) {
            self.nonScientific = ns
            self.scientific = nil
    }
    private func set (_ s: Scientific) {
            self.nonScientific = nil
            self.scientific = s
    }
    
    func update(with number: Number, digitsInExpandedDisplay: Int = DisplayData.digitsInExpandedDisplay) {
        let gmp: Gmp
        if let str = number.str {
            if str.count <= DisplayData.digitsInOneLine {
                    set(str)
                return
            } else {
                /// str, but too long for one line
                gmp = Gmp(str)
            }
        } else {
            gmp = number.gmp!
        }
        
        //print("DisplayData init(gmp) START")
        if gmp.NaN {
            set("not real")
            return
        }
        if gmp.inf {
            set("too large for me")
            return
        }
        
        if gmp.isZero {
            set("0")
            return
        }
        
        //print("data 1")
        let data = gmp.data(digitsInExpandedDisplay)
        //print("data 2")
        
        /// can be perfectly represented as Integer in one line?
        
        /// mantissa not too long for the exponent?
        if data.mantissa.count <= data.exponent + 1 {
            /// the integer fits into one line?
            if data.exponent < DisplayData.digitsInOneLine {
                var integerString = data.mantissa
                /// zero padding
                for _ in 0..<(data.exponent+1-integerString.count) {
                    integerString += "0"
                }
                if data.negative { integerString = "-" + integerString }
                if integerString.count <= DisplayData.digitsInOneLine {
                    set(integerString)
                    return
                }
            }
        }
        
        /// Can be represent as float?
        if data.exponent >= 0 {
            /// X,xxxx
            if data.exponent < DisplayData.digitsInOneLine - 3 {
                /// can be displayed
                var floatString = data.mantissa
                let index = floatString.index(floatString.startIndex, offsetBy: data.exponent+1)
                floatString.insert(",", at: index)
                if data.negative { floatString = "-" + floatString }
                set(floatString)
                return
            }
        } else {
            /// 0,xxxx
            if -data.exponent < DisplayData.digitsInOneLine - 3 {
                /// can be displayed
                var floatString = "0,"
                let zeroes = -data.exponent
                for _ in 1..<zeroes {
                    floatString += "0"
                }
                floatString += data.mantissa
                if data.negative { floatString = "-" + floatString }
                set(floatString)
                return
            }
        }
        
        /// needs to be displayed in scientific notation
        let exponent = "e\(data.exponent)"
        var mantissa = data.mantissa
        let indexOne = mantissa.index(mantissa.startIndex, offsetBy: 1)
        mantissa.insert(",", at: indexOne)
        if mantissa.count <= 2 { mantissa += "0" } /// e.g. 1e16 -> 1,e16 -> 1,0e16
        if data.negative { mantissa = "-" + mantissa }
        set(Scientific(mantissa, exponent))
        return
    }
}
