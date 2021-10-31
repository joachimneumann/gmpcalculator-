//
//  CalculatorAppCatalyst.swift
//  Calculator
//
//  Created by Joachim Neumann on 10/24/21.
//

import SwiftUI

#if targetEnvironment(macCatalyst)


struct CalculatorAppCatalyst: Scene {

    let brain = Brain()
    var body: some Scene {
        WindowGroup {
            ZStack {
                TE.appBackgroundColor
                    .ignoresSafeArea()
                /// Sizes are hardcoded for Mac.
                /// Therefore, I call default initializer of TE, not giving it the screenSizze
                MainView(brain: brain, t: TE())
            }
        }
        .commands() {
            CalculatorCommands(brain: brain)
        }
    }
}

class SceneDelegate: NSObject, UIWindowSceneDelegate, ObservableObject {
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .forEach { windowScene in
                windowScene.sizeRestrictions?.minimumSize = CGSize(width: TE.macWindowWidth, height: TE.macWindowHeight)
                windowScene.sizeRestrictions?.maximumSize = CGSize(width: TE.macWindowWidth, height: TE.macWindowHeight)
            }
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        if let titlebar = windowScene.titlebar {
            titlebar.titleVisibility = .hidden
            titlebar.toolbar = nil
        }
    }
}


class MyAppDelegate: UIResponder, UIApplicationDelegate {
    override func buildMenu(with builder: UIMenuBuilder) {
        super.buildMenu(with: builder)
        builder.remove(menu: .file)
        builder.remove(menu: .services)
        builder.remove(menu: .help)
        builder.remove(menu: .window)
        builder.remove(menu: .view)
        builder.remove(menu: .edit)
        builder.remove(menu: .undoRedo)
        builder.remove(menu: .standardEdit)
        builder.remove(menu: .spelling)
        builder.remove(menu: .substitutions)
        builder.remove(menu: .transformations)
        builder.remove(menu: .speech)
        builder.remove(menu: .hide)
        builder.remove(menu: .format)
        builder.remove(menu: .toolbar)
    }
    
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = SceneDelegate.self
        return sceneConfig
    }
}

#else
/// nothing to compile here
#endif
