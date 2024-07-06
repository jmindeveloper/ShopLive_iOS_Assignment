//
//  NetworkManager.swift
//  ShopLive_iOS_Assignment
//
//  Created by J_Min on 7/3/24.
//

import Foundation

protocol NetworkManagerProtocol {
    var characterPublisher: SLCurrentValueSubject<[MarvelCharacter]> { get }
    
    init(session: URLSessionProtocol)
    
    func getMarvelCharacters(resource: Resource) throws
    func getImageData(url: URL?) async throws -> Data
}

final class NetworkManager: NetworkManagerProtocol {
    
    // MARK: - Properties
    private let session: URLSessionProtocol
    private var requestTask: Task<(), Error>?
    let characterPublisher = SLCurrentValueSubject<[MarvelCharacter]>([])
    
    init(session: URLSessionProtocol = URLSession(configuration: .default)) {
        self.session = session
    }
    
    // MARK: - Method
    private func getMarvelCharacters(request: URLRequest?) async throws -> [MarvelCharacter] {
        if !NetworkCheck.shared.isConnectedPublisher.value {
            throw URLError(.notConnectedToInternet)
        }
        
        guard let request = request else {
            throw URLError(.badURL)
        }
        let (data, response) = try await session.data(for: request)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        do {
            let characters = try JSONDecoder().decode(MarvelCharacterAPIResult.self, from: data)
            return characters.data.results
        } catch {
            print(error.localizedDescription)
        }
        
        return []
    }
    
    func getMarvelCharacters(resource: Resource) throws {
        requestTask?.cancel()
        requestTask = Task {
            let characters = try await getMarvelCharacters(request: resource.urlRequest)
            characterPublisher.send(characters)
        }
    }
    
    func getImageData(url: URL?) async throws -> Data {
        if !NetworkCheck.shared.isConnectedPublisher.value {
            throw URLError(.notConnectedToInternet)
        }
        
        guard let url = url else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        return data
    }
    
    private func cancelRequest() {
        requestTask?.cancel()
    }
}
