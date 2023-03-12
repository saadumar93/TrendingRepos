//
//  TrendingRepos.swift
//  TrendingRepos
//
//  Created by Saad Umar on 3/7/23.
//

import Foundation
import CoreData

///ViewModel for TrendingReposView
class TrendingGithubRepos: ObservableObject {
    
    private let persistenceManager: PersistenceManager
    private let service: Service
    
    @MainActor
    @Published var repos: [Repository] = []
    
    /// Depency injecting persistence manager as it will depend upon the context
    /// Normally we would be using PersistenceManager.shared through out our life cycle
    /// But there can be instances where would want to mock it with something else
    /// For examples, in tests, we would want an inMemory persistence manager with run time dummy data
    init(with service: Service = NetworkService(), persistenceManager: PersistenceManager = PersistenceManager.shared) {
        self.service = service
        self.persistenceManager = persistenceManager
        Task { @MainActor in
            self.repos = try await self.fetchAllRepositories()
        }
    }
    
    private func getAllPersistentRepositories() -> [Repository] {
        var repositories:[Repository] = []
        // Create a fetch request for the Repository entity
        let fetchRequest: NSFetchRequest<Repository> = Repository.fetchRequest()
        
        do {
            // Execute the fetch request on the managed object context
            let fetchedRepositories = try persistenceManager.container.viewContext.fetch(fetchRequest)
            
            // Use the fetched objects
            repositories = fetchedRepositories
        } catch {
            // Handle any errors
            print("Failed to fetch Repositories: \(error)")
        }
        return repositories
    }
}

extension Repository {
    ///Convenience init to initialize Repository Core Data model from the Repo App Model
    convenience init(from model:Repo) {
        self.init(context: PersistenceManager.shared.container.viewContext)
        self.authorImageURL = model.owner.avatarURL
        self.authorName = model.owner.login
        self.repoName = model.name
        self.repoDesc = model.itemDescription
        self.language = model.language
        self.stars = Int32(model.stargazersCount)
    }
}

extension TrendingGithubRepos {
    
    ///Standard async await function, meant to be called in Task
    ///
    func fetchAllRepositories() async throws -> [Repository] {
        var request = ReposRequest()
        let result = try await service.get(request: request)
        
        switch result {
        case .success(let data):
            let decoder = JSONDecoder()
            return try decoder.decode(TrendingReposModel.self, from: data).items.repositories()
        case .failure(_):
            return []
            
        }
        
    }
    
}
///Concrete request to get all repos
struct ReposRequest: Request {
    var urlRequest: URLRequest {
        let url = URL(string: "https://api.github.com/search/repositories?q=language=+sort:stars")
        let urlRequest = URLRequest(url: url!)
        return urlRequest
    }
}

extension Array where Element == Repo {
    ///Converts the given Repo Array to Repository Array
    ///Distinguish: Repo is app model where as Repository is Core Data model
    func repositories() -> [Repository] {
        var repositories: [Repository] = []
        for item in self {
            repositories.append(Repository(from: item))
        }
        return repositories
    }
}
