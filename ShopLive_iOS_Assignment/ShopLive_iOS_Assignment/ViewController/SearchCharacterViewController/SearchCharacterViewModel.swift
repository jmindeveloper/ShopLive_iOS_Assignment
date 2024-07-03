//
//  SearchCharacterViewModel.swift
//  ShopLive_iOS_Assignment
//
//  Created by J_Min on 7/4/24.
//

import Foundation
import Combine
import CryptoKit

final class SearchCharacterViewModel {
    
    // MARK: - Properties
    private let networkManager = NetworkManager()
    private var pagenationCount = 0
    private let apiCallLimitCount = 10
    
    var marvelCharacters: [MarvelCharacter] = [] {
        didSet {
            pagenationCount += 10
            collectionViewUpdatePublisher.send()
        }
    }
    var searchCharacterName: String = ""
    let collectionViewUpdatePublisher = PassthroughSubject<Void, Never>()
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        binding()
    }
    
    private func binding() {
        networkManager.characterPublisher
            .sink { [weak self] characters in
                self?.marvelCharacters.append(contentsOf: characters)
                print(characters.map { $0.name })
            }.store(in: &subscriptions)
    }
    
    // MARK: - Method
    func getMarvelCharacters() {
        let ts = String(Date().timeIntervalSince1970)
        guard let hashKey = getAPICallHash(ts),
              let publicKey = Bundle.main.PUBLIC_KEY else {
            return
        }
        
        let resource = Resource(
            base: "https://gateway.marvel.com:443",
            path: "/v1/public/characters",
            params: [
                "nameStartsWith": searchCharacterName,
                "ts": ts,
                "apikey": publicKey,
                "hash": hashKey,
                "limit": String(apiCallLimitCount),
                "offset": String(pagenationCount)
            ]
        )
        
        do {
            try networkManager.getMarvelCharacters(resource: resource)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func MD5(data: String) -> String {
        let hash = Insecure.MD5.hash(data: data.data(using: .utf8) ?? Data())
        
        return hash.map {
            String(format: "%02hhx", $0)
        }.joined()
    }
    
    private func getAPICallHash(_ ts: String) -> String? {
        guard let privateKey = Bundle.main.PRIVATE_KEY,
              let publicKey = Bundle.main.PUBLIC_KEY else {
            return nil
        }
        
        return MD5(data: "\(ts)\(privateKey)\(publicKey)")
    }
}
