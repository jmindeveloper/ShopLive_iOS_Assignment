//
//  SearchCharacterViewModel.swift
//  ShopLive_iOS_Assignment
//
//  Created by J_Min on 7/4/24.
//

import Foundation
import Combine
import CryptoKit

protocol SearchCharacterViewModelProtocol {
    var marvelCharacters: [MarvelCharacter] { get set }
    var favoriteMarvelCharacters: [FavoriteMarvelCharacter] { get set }
    var searchCharacterName: String { get set }
    var collectionViewUpdatePublisher: PassthroughSubject<Void, Never> { get }
    
    func getMarvelCharacters(query: String?)
    func checkExistInFavoriteCharacter(index: Int) -> Bool
    func tapMarvelCharacterCardAction(index: Int)
}

final class SearchCharacterViewModel: SearchCharacterViewModelProtocol {
    
    // MARK: - Properties
    private let networkManager = NetworkManager()
    private let coreDataManager = CoreDataManager()
    private var pagenationCount = 0
    private let apiCallLimitCount = 10
    private var isDonePagenation: Bool = false
    
    var marvelCharacters: [MarvelCharacter] = [] {
        didSet {
            pagenationCount += 9
            collectionViewUpdatePublisher.send()
        }
    }
    var favoriteMarvelCharacters: [FavoriteMarvelCharacter] = [] {
        didSet {
            collectionViewUpdatePublisher.send()
        }
    }
    @Published var searchCharacterName: String = ""
    let collectionViewUpdatePublisher = PassthroughSubject<Void, Never>()
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        binding()
        coreDataManager.getFavoriteCharacter()
    }
    
    private func binding() {
        networkManager.characterPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] characters in
                self?.marvelCharacters.append(contentsOf: characters)
                if characters.isEmpty {
                    self?.isDonePagenation = true
                }
                print(characters.map { $0.id })
            }.store(in: &subscriptions)
        
        coreDataManager.favoriteCharacterPublisher
            .sink { [weak self] characters in
                print(characters.count)
                self?.favoriteMarvelCharacters = characters
            }.store(in: &subscriptions)
        
        $searchCharacterName
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .sink { [weak self] text in
                self?.isDonePagenation = false
                if text.count >= 2 {
                    self?.pagenationCount = 0
                    self?.marvelCharacters.removeAll()
                    self?.getMarvelCharacters(query: text)
                }
            }.store(in: &subscriptions)
    }
    
    // MARK: - Method
    
    /// query가 비었
    func getMarvelCharacters(query: String? = nil) {
        if isDonePagenation { return }
        let ts = String(Date().timeIntervalSince1970)
        guard let hashKey = getAPICallHash(ts),
              let publicKey = Bundle.main.PUBLIC_KEY else {
            return
        }
        
        let query = query == nil ? searchCharacterName : query!
        
        let resource = Resource(
            base: "https://gateway.marvel.com:443",
            path: "/v1/public/characters",
            params: [
                "nameStartsWith": query,
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
    
    // marvelCharacter의 요소가 favorite에 속하는지 확인하는 함수
    func checkExistInFavoriteCharacter(index: Int) -> Bool {
        let character = marvelCharacters[index]
        
        return favoriteMarvelCharacters.contains { $0.id == character.id }
    }
    
    func tapMarvelCharacterCardAction(index: Int) {
        if checkExistInFavoriteCharacter(index: index) {
            deleteFavoriteMarvelCharacter(index: index)
        } else {
            saveFavoriteMarvelCharacter(index: index)
        }
    }
    
    private func saveFavoriteMarvelCharacter(index: Int) {
        let character = marvelCharacters[index]
        Task {
            do {
                let imageURL = URL(string: "\(character.thumbnail.path).\(character.thumbnail.extension)")
                let imageData = try await networkManager.getImageData(url: imageURL)
                
                let characterEntity = FavoriteMarvelCharacterEntity(
                    id: Int64(character.id),
                    name: character.name,
                    description: character.description,
                    date: Date(),
                    thumbnail: imageData
                )
                
                DispatchQueue.main.async { [weak self] in
                    self?.coreDataManager.saveFavoriteCharacter(entity: characterEntity)
                }
                
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func deleteFavoriteMarvelCharacter(index: Int) {
        let character = marvelCharacters[index]
        if let favoriteCharacter = favoriteMarvelCharacters.first(where: { $0.id == character.id }) {
            coreDataManager.deleteFavoriteCharacter(character: favoriteCharacter)
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
