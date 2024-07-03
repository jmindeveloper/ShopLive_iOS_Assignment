//
//  NetworkManager.swift
//  ShopLive_iOS_Assignment
//
//  Created by J_Min on 7/3/24.
//

import Foundation
import Combine

final class NetworkManager {
    
    // MARK: - Properties
    private let session: URLSession
    private var requestTask: Task<(), Error>?
    let characterPublisher = CurrentValueSubject<[MarvelCharacter], Never>([])
    
    init() {
        self.session = URLSession(configuration: .default)
    }
    
    // MARK: - Method
    private func getMarvelCharacters(request: URLRequest?) async throws -> [MarvelCharacter] {
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
        requestTask = Task {
            let characters = try await getMarvelCharacters(request: resource.urlRequest)
            characterPublisher.send(characters)
        }
    }
}
