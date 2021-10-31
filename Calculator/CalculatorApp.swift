//
//  CalculatorApp.swift
//  Calculator
//
//  Created by Joachim Neumann on 20/09/2021.
//

import SwiftUI

@main
struct CalculatorApp: App {

    @UIApplicationDelegateAdaptor var mydelegate: MyAppDelegate

    var body: some Scene {
#if targetEnvironment(macCatalyst)
        CalculatorAppCatalyst()
#else
        CalculatorAppiOS()
#endif
    }
}
