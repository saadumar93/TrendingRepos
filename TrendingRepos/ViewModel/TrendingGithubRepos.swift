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
        self.persistenceManager.deleteAllData("Repository") //clear CoreData for fresh storage
        Task {
            await self.fetchAllRepositories()
        }
    }
    
    func retryFetchRepos() {
        self.persistenceManager.deleteAllData("Repository") //clear CoreData for fresh storage
        Task {
            await self.fetchAllRepositories()
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
    
    ///Call this function after have successfully retrieved repos from network and set to self.repos
    private func persistAllRepositories() {
        do {
            try self.persistenceManager.container.viewContext.save()

        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

extension Repository {
    ///Convenience init to initialize Repository Core Data model from the Repo App Model
    convenience init(from model:Repo) {
        self.init(context: PersistenceManager.shared.container.viewContext)
        self.id = UUID()
        self.cachedDate = Date()
        self.authorImageURL = model.owner.avatarURL
        self.authorName = model.owner.login
        self.repoName = model.name
        self.repoDesc = model.itemDescription
        self.language = model.language
        self.stars = Int32(model.stargazersCount)
    }
    ///Convenience init for empty views
    convenience init(with id: UUID) {
        self.init(context: PersistenceManager.shared.container.viewContext)
        self.id = id
        self.cachedDate = Date()
    }
}

extension TrendingGithubRepos {
    ///Standard async  function, meant to be awaited  in Task
    @MainActor
    func fetchAllRepositories() async {
        let request = ReposRequest()
        var fetchedRepos:[Repository] = []
        
        do {
            let result = try await service.get(request: request)
            
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                fetchedRepos = try decoder.decode(TrendingReposModel.self, from: data).items.repositories()
            case .failure(_):
                break
            }
        } catch {
            print(error.localizedDescription)
        }
        if !fetchedRepos.isEmpty {
            self.repos = fetchedRepos
            //TODO: do the below fix and call this function to saving the repos model in CoreData
            //self.persistAllRepositories()
        } //else {
        //FIXME: Complete the following implementation to have the user at least see last fetched api response, incase off no internet :)
//            let persistentRepos = getAllPersistentRepositories()
//            if !persistentRepos.isEmpty {
//                self.repos = persistentRepos
//            }
//        }
    }
}
///Concrete request to get all repos
///Discussion: We are not passing any value for cachePolicy in URLRequest.init() which defaults to useProtocolCachePolicy
///which is well illustrated in Figure 1 here: https://developer.apple.com/documentation/foundation/nsurlrequest/cachepolicy/useprotocolcachepolicy

struct ReposRequest: Request {
    var urlRequest: URLRequest {
        let url = URL(string: AppURLS.Endpoints.trendingRepos)
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
