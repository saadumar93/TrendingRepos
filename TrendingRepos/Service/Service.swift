//
//  Service.swift
//  TrendingRepos
//
//  Created by Saad Umar on 3/11/23.
//
import Foundation
/// Create a concrete request type for each request your app supports
/// Usage:
/// ```
/// class TrendingReposAdditionRequest: Request {
///     var urlRequest: URLRequest {
///         return request
///     }
/// }
/// ```
protocol Request {
    var urlRequest: URLRequest { get }
}

/// An abstract service type that can have multiple implementation for example - a NetworkService that gets a resource from the Network or a DiskService that gets a resource from Disk
protocol Service {
    func get(request: Request) async throws -> Result<Data,Error>
}

/// A concrete implementation of Service class responsible for getting a Network resource
final class NetworkService: Service {
    func get(request: Request) async throws -> Result<Data, Error> {
        guard let url = request.urlRequest.url else {
            return .failure(ServiceError.invalidURL)
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        return .success(data)
    }
    
    enum ServiceError: Error {
        case invalidURL
        case noData
    }
    
//    func get(request: Request, completion: @escaping (Result<Data, Error>) -> Void) {
//        URLSession.shared.dataTask(with: request.urlRequest) { (data, response, error) in
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//            guard let data = data else {
//                completion(.failure(ServiceError.noData))
//                return
//            }
//            completion(.success(data))
//        }.resume()
//    }
}
