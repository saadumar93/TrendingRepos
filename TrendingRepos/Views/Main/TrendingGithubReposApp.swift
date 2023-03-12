//
//  TrendingReposApp.swift
//  TrendingRepos
//
//  Created by Saad Umar on 3/2/23.
//

import SwiftUI
import URLImage
import URLImageStore

///For versions greater than iOS 13, Use 'App', 'Scene' and 'WindowGroup'
@available(iOS 14.0, *)
struct TrendingReposApp: App {
    var networkMonitor = NetworkMonitor()
    var body: some Scene {
        let urlImageService = URLImageService(fileStore: URLImageFileStore(),
                                                  inMemoryStore: URLImageInMemoryStore())
        WindowGroup {
            TrendingReposView(viewModel: TrendingGithubRepos())
                .environment(\.urlImageService, urlImageService)
                .environmentObject(networkMonitor)
        }
    }
}

@main
///To make the app backward compatible with iOS 13, Since 'App', 'Scene' and 'WindowGroup' are only available iOS 14 and above
class TrendingReposAppWrapper {
    static func main() {
        if #available(iOS 14.0, *) {
            TrendingReposApp.main()
        }
        else {
            ///Known issue on iOS 13, UIHostingController not taking up full frame
            UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, nil, NSStringFromClass(SceneDelegate.self))
        }
    }
}
