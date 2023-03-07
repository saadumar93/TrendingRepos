//
//  TrendingReposApp.swift
//  TrendingRepos
//
//  Created by Saad Umar on 3/2/23.
//

import SwiftUI

@main
struct TrendingReposApp: App {
    var body: some Scene {
        WindowGroup {
            TrendingReposView(viewModel: TrendingGithubRepos())
        }
    }
}
