//
//  SceneDelegate.swift
//  TrendingRepos
//
//  Created by Saad Umar on 3/10/23.
//

import SwiftUI

///Backward Compatibilty for iOS 13, Since 'App', 'Scene' and 'WindowGroup' are only available iOS 14 and above. So iOS version 13 will use SceneDelegate instead via runtime check
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let trendingReposView = TrendingReposView(viewModel: TrendingGithubRepos())

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: trendingReposView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}
