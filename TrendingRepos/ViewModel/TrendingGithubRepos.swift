//
//  TrendingRepos.swift
//  TrendingRepos
//
//  Created by Saad Umar on 3/7/23.
//

import Foundation
import CoreData

//ViewModel for TrendingReposView
class TrendingGithubRepos {

    let persistenceManager: PersistenceManager
    var repos: [Repo] {
        get { getAllRepos() }
    }
    
    /// Depency injecting persistence manager as it will depend upon the context
    /// Normally we would be using PersistenceManager.shared through out our life cycle
    /// But there can be instances where would want to mock it with something else
    /// For examples, in tests, we would want an inMemory persistence manager with run time dummy data
    init(persistenceManager: PersistenceManager = PersistenceManager.shared) {
        self.persistenceManager = persistenceManager
    }
    
    private func getAllRepos() -> [Repo] {
        var repos:[Repo] = []
        // Create a fetch request for the Repo entity
        let fetchRequest: NSFetchRequest<Repo> = Repo.fetchRequest()

        do {
            // Execute the fetch request on the managed object context
            let fetchedRepos = try persistenceManager.container.viewContext.fetch(fetchRequest)

            // Use the fetched objects
            repos = fetchedRepos
        } catch {
            // Handle any errors
            print("Failed to fetch repos: \(error)")
        }
        return repos
    }
}
