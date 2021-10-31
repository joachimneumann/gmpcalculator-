//
//  CalculatorAppiOS.swift
//  Calculator
//
//  Created by Joachim Neumann on 10/24/21.
//

import SwiftUI

#if targetEnvironment(macCatalyst)
/// nothing to compile here
#else

struct CalculatorAppiOS: Scene {
    
    let brain = Brain()

    var body: some Scene {
        WindowGroup {
            /// The factor 1.5 is a little hack to prevent that the white background
            /// shows up during device orientation change rotation
            let expandedDeviceSize: CGFloat = 1.5 * max(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
            iOSSize(brain: brain)
                .statusBar(hidden: true)
                .background(Rectangle()
                                .frame(width: expandedDeviceSize,
                                       height: expandedDeviceSize,
                                       alignment: .center)
                                .foregroundColor(TE.appBackgroundColor)
                                .ignoresSafeArea())
        }
        .commands() {
            CalculatorCommands(brain: brain)
        }
    }
}

class MyAppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window:UIWindow?) -> UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .landscape
        } else {
            return .all
        }
    }
}
#endif


