//
//  NumberKeys.swift
//  Calculator
//
//  Created by Joachim Neumann on 20/09/2021.
//

import SwiftUI


struct NumberKeys: View {
    @ObservedObject var brain: Brain
    let t: TE
    let separator = Locale.current.decimalSeparator!

    var body: some View {
        VStack(spacing: t.spaceBetweenkeys) {
            HStack(spacing: t.spaceBetweenkeys) {
                Key("C", requiresValidNuber: false, brain: brain, t: t, keyProperties: t.ac_plus_minus_percentProperties)
                Key("+/-", requiresValidNuber: true, brain: brain, t: t, keyProperties: t.ac_plus_minus_percentProperties)
                Key("%", requiresValidNuber: true, brain: brain, t: t, keyProperties: t.ac_plus_minus_percentProperties)
                Key("/", requiresValidNuber: true, brain: brain, t: t, keyProperties: t.colorOpProperties)
            }
            HStack(spacing: t.spaceBetweenkeys) {
                Key("7", requiresValidNuber: false, brain: brain, t: t, keyProperties: t.digits_1_9)
                Key("8", requiresValidNuber: false, brain: brain, t: t, keyProperties: t.digits_1_9)
                Key("9", requiresValidNuber: false, brain: brain, t: t, keyProperties: t.digits_1_9)
                Key("x", requiresValidNuber: true, brain: brain, t: t, keyProperties: t.colorOpProperties)
            }
            HStack(spacing: t.spaceBetweenkeys) {
                Key("4", requiresValidNuber: false, brain: brain, t: t, keyProperties: t.digits_1_9)
                Key("5", requiresValidNuber: false, brain: brain, t: t, keyProperties: t.digits_1_9)
                Key("6", requiresValidNuber: false, brain: brain, t: t, keyProperties: t.digits_1_9)
                Key("-", requiresValidNuber: true, brain: brain, t: t, keyProperties: t.colorOpProperties)
            }
            HStack(spacing: t.spaceBetweenkeys) {
                Key("1", requiresValidNuber: false, brain: brain, t: t, keyProperties: t.digits_1_9)
                Key("2", requiresValidNuber: false, brain: brain, t: t, keyProperties: t.digits_1_9)
                Key("3", requiresValidNuber: false, brain: brain, t: t, keyProperties: t.digits_1_9)
                Key("+", requiresValidNuber: true, brain: brain, t: t, keyProperties: t.colorOpProperties)
            }
            HStack(spacing: t.spaceBetweenkeys) {
                Key("0", requiresValidNuber: false, brain: brain, t: t, keyProperties: t.digits_0)
                Key(separator, requiresValidNuber: false, brain: brain, t: t, keyProperties: t.digits_1_9)
                Key("=", requiresValidNuber: true, brain: brain, t: t, keyProperties: t.colorOpProperties)
            }
        }
    }
}

