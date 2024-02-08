//
//  WhereSceneDelegate.swift
//  Where42
//
//  Created by 현동호 on 2/7/24.
//

import SwiftUI

final class WhereSceneDelegate: UIResponder, UIWindowSceneDelegate, ObservableObject {
    var toastState: Toast? {
        didSet(oldValue) {
            if oldValue == nil {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
//                    self.setupToastWindow()
//                }
                setupToastWindow()
            }
        }
    }

    var toastWindow: UIWindow?
    weak var windowScene: UIWindowScene?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        print(scene)
        windowScene = scene as? UIWindowScene
    }

    func setupToastWindow() {
        guard let windowScene = windowScene else {
            return
        }

        let viewController = UIHostingController(
            rootView: ToastScene()
                .environmentObject(MainViewModel.shared)
        )

        viewController.view.backgroundColor = .clear

        let window = PassThroughWindow(windowScene: windowScene)
        window.rootViewController = viewController

        window.isHidden = false

        toastWindow = window
    }
}