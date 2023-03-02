//
//  TrendingGithubReposApp.swift
//  TrendingGithubRepos
//
//  Created by Tixsee on 3/2/23.
//

import SwiftUI

@main
struct TrendingGithubReposApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
