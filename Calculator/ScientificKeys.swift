//
//  ScientificKeys.swift
//  Calculator
//
//  Created by Joachim Neumann on 23/09/2021.
//

import SwiftUI

struct ScientificKeys: View {
    @ObservedObject var brain: Brain
    let t: TE
    
    var body: some View {
        VStack(spacing: t.spaceBetweenkeys) {
            HStack(spacing: t.spaceBetweenkeys) {
                Key("(", requiresValidNuber: true, brain: brain, t: t, keyProperties: t.scientificProperties)
                Key(")", requiresValidNuber: true, brain: brain, t: t, keyProperties: t.scientificProperties)
                Key("mc", requiresValidNuber: false, brain: brain, t: t, keyProperties: t.scientificProperties)
                Key("m+", requiresValidNuber: true, brain: brain, t: t, keyProperties: t.scientificProperties)
                Key("m-", requiresValidNuber: true, brain: brain, t: t, keyProperties: t.scientificProperties)
                Key("mr", requiresValidNuber: false, brain: brain, t: t, keyProperties: t.scientificProperties)
            }
            HStack(spacing: t.spaceBetweenkeys) {
                Key("2nd", requiresValidNuber: false, brain: brain, t: t, keyProperties: t.scientificProperties)
                Key("x^2", requiresValidNuber: true, brain: brain, t: t, keyProperties: t.scientificProperties)
                Key("x^3", requiresValidNuber: true, brain: brain, t: t, keyProperties: t.scientificProperties)
                Key("x^y", requiresValidNuber: true, brain: brain, t: t, keyProperties: t.scientificProperties)
                Key(brain.secondKeys ? "y^x" : "e^x", requiresValidNuber: true, brain: brain, t: t, keyProperties: t.scientificProperties)
                Key(brain.secondKeys ? "2^x" : "10^x", requiresValidNuber: true, brain: brain, t: t, keyProperties: t.scientificProperties)
            }
            HStack(spacing: t.spaceBetweenkeys) {
                Key("One_x", requiresValidNuber: true, brain: brain, t: t, keyProperties: t.scientificProperties)
                Key("√", requiresValidNuber: true, brain: brain, t: t, keyProperties: t.scientificProperties)
                Key("3√", requiresValidNuber: true, brain: brain, t: t, keyProperties: t.scientificProperties)
                Key("y√", requiresValidNuber: true, brain: brain, t: t, keyProperties: t.scientificProperties)
                Key(brain.secondKeys ? "logy" : "ln", requiresValidNuber: true, brain: brain, t: t, keyProperties: t.scientificProperties)
                Key(brain.secondKeys ? "log2" : "log10", requiresValidNuber: true, brain: brain, t: t, keyProperties: t.scientificProperties)
            }
            HStack(spacing: t.spaceBetweenkeys) {
                Key("x!", requiresValidNuber: true, brain: brain, t: t, keyProperties: t.scientificProperties)
                Key(brain.rad ? (brain.secondKeys ? "asin" : "sin") : (brain.secondKeys ? "asinD" : "sinD"), requiresValidNuber: true, brain: brain, t: t, keyProperties: t.scientificProperties)
                Key(brain.rad ? (brain.secondKeys ? "acos" : "cos") : (brain.secondKeys ? "acosD" : "cosD"), requiresValidNuber: true, brain: brain, t: t, keyProperties: t.scientificProperties)
                Key(brain.rad ? (brain.secondKeys ? "atan" : "tan") : (brain.secondKeys ? "atanD" : "tanD"), requiresValidNuber: true, brain: brain, t: t, keyProperties: t.scientificProperties)
                Key("e", requiresValidNuber: false, brain: brain, t: t, keyProperties: t.scientificProperties)
                Key("EE", requiresValidNuber: true, brain: brain, t: t, keyProperties: t.scientificProperties)
            }
            HStack(spacing: t.spaceBetweenkeys) {
                Key(brain.rad ? "Deg" : "Rad", requiresValidNuber: true, brain: brain, t: t, keyProperties: t.scientificProperties)
                Key(brain.secondKeys ? "asinh" : "sinh", requiresValidNuber: true, brain: brain, t: t, keyProperties: t.scientificProperties)
                Key(brain.secondKeys ? "acosh" : "cosh", requiresValidNuber: true, brain: brain, t: t, keyProperties: t.scientificProperties)
                Key(brain.secondKeys ? "atanh" : "tanh", requiresValidNuber: true, brain: brain, t: t, keyProperties: t.scientificProperties)
                Key("π", requiresValidNuber: false, brain: brain, t: t, keyProperties: t.scientificProperties)
                Key("Rand", requiresValidNuber: false, brain: brain, t: t, keyProperties: t.scientificProperties)
            }
        }
    }
}
