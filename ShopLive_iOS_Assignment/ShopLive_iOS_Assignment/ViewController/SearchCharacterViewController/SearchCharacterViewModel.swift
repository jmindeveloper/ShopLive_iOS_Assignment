//
//  SearchCharacterViewModel.swift
//  ShopLive_iOS_Assignment
//
//  Created by J_Min on 7/4/24.
//

import Foundation
import Combine
import CryptoKit
import SDWebImage

protocol SearchCharacterViewModelProtocol {
    var marvelCharacters: [MarvelCharacter] { get set }
    var favoriteMarvelCharacters: [FavoriteMarvelCharacter] { get set }
    var searchCharacterNamePublisher: SLCurrentValueSubject<String> { get }
    var collectionViewUpdatePublisher: SLPassthroughSubject<Int?> { get }
    var isSavingFavoriteCharacterPublisher: SLPassthroughSubject<Bool> { get }
    var errorPublisher: SLPassthroughSubject<Error> { get }
    var isFetchingCharacters: Bool { get set }
    
    init(networkManager: NetworkManagerProtocol, coreDataManager: CoreDataManagerProtocol)
    
    func getMarvelCharacters(query: String?)
    func checkExistInFavoriteCharacter(index: Int) -> Bool
    func tapMarvelCharacterCardAction(index: Int)
}

extension SearchCharacterViewModelProtocol {
    func getMarvelCharacters(query: String? = nil) {
        getMarvelCharacters(query: query)
    }
}

final class SearchCharacterViewModel: SearchCharacterViewModelProtocol {
    
    // MARK: - Properties
    private let networkManager: NetworkManagerProtocol
    private let coreDataManager: CoreDataManagerProtocol
    private var paginationCount = 0
    private let apiCallLimitCount = 10
    private var isDonePagenation: Bool = false
    var isFetchingCharacters: Bool = false
    
    var marvelCharacters: [MarvelCharacter] = [] {
        didSet {
            if !marvelCharacters.isEmpty {
                paginationCount += 10
            }
            isFetchingCharacters = false
            collectionViewUpdatePublisher.send(nil)
        }
    }
    var favoriteMarvelCharacters: [FavoriteMarvelCharacter] = [] {
        didSet {
            collectionViewUpdatePublisher.send(nil)
        }
    }

    let collectionViewUpdatePublisher = SLPassthroughSubject<Int?>()
    let isSavingFavoriteCharacterPublisher = SLPassthroughSubject<Bool>()
    var searchCharacterNamePublisher = SLCurrentValueSubject<String>("")
    let errorPublisher = SLPassthroughSubject<Error>()
    private var subscriptions = Set<SLAnyCancellable>()
    private var subscription = Set<AnyCancellable>()
    
    init(networkManager: NetworkManagerProtocol, coreDataManager: CoreDataManagerProtocol) {
        self.coreDataManager = coreDataManager
        self.networkManager = networkManager
        binding()
    }
    
    private func binding() {
        networkManager.characterPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] characters in
                self?.marvelCharacters.append(contentsOf: characters)
                if characters.isEmpty {
                    self?.isDonePagenation = true
                }
            }.store(in: &subscriptions)
        
        coreDataManager.favoriteCharacterPublisher
            .sink { [weak self] characters in
                self?.favoriteMarvelCharacters = characters
            }.store(in: &subscriptions)
        
        coreDataManager.errorPublisher
            .sink { [weak self] error in
                self?.errorPublisher.send(error)
            }.store(in: &subscriptions)
        
        searchCharacterNamePublisher
            .debounce(for: 0.3, queue: .main)
            .sink { [weak self] text in
                self?.isDonePagenation = false
                if text.count >= 2 {
                    self?.paginationCount = 0
                    self?.marvelCharacters.removeAll()
                    self?.getMarvelCharacters(query: text)
                }
            }.store(in: &subscriptions)
        
        NetworkCheck.shared.isConnectedPublisher
            .sink { [weak self] isConnected in
                if !isConnected {
                    self?.errorPublisher.send(URLError(.notConnectedToInternet))
                }
            }.store(in: &subscriptions)
    }
    
    // MARK: - Method
    
    // query가 nil일 경우 기존 쿼리로 검색
    func getMarvelCharacters(query: String? = nil) {
        if isDonePagenation { return }
        if !NetworkCheck.shared.isConnectedPublisher.value {
            errorPublisher.send(URLError(.notConnectedToInternet))
            return
        }
        isFetchingCharacters = true
        collectionViewUpdatePublisher.send(1)
        let ts = String(Date().timeIntervalSince1970)
        guard let hashKey = getAPICallHash(ts),
              let publicKey = Bundle.main.PUBLIC_KEY else {
            return
        }
        
        let query = query == nil ? searchCharacterNamePublisher.value : query!
        
        let resource = Resource(
            base: "https://gateway.marvel.com:443",
            path: "/v1/public/characters",
            params: [
                "nameStartsWith": query,
                "ts": ts,
                "apikey": publicKey,
                "hash": hashKey,
                "limit": String(apiCallLimitCount),
                "offset": String(paginationCount)
            ]
        )
        
        do {
            try networkManager.getMarvelCharacters(resource: resource)
        } catch {
            errorPublisher.send(error)
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
                DispatchQueue.main.async { [weak self] in
                    self?.isSavingFavoriteCharacterPublisher.send(true)
                }
                let imageURL = URL(string: "\(character.thumbnail.path).\(character.thumbnail.extension)")
                let imageData = try await getCharacterThumbnailImageData(url: imageURL)
                
                let characterEntity = FavoriteMarvelCharacterEntity(
                    id: Int64(character.id),
                    name: character.name,
                    description: character.description,
                    date: Date(),
                    thumbnail: imageData
                )
                
                DispatchQueue.main.async { [weak self] in
                    self?.coreDataManager.saveFavoriteCharacter(entity: characterEntity)
                    self?.isSavingFavoriteCharacterPublisher.send(false)
                }
                
            } catch {
                errorPublisher.send(error)
                print(error.localizedDescription)
            }
        }
    }
    
    private func getCharacterThumbnailImageData(url: URL?) async throws -> Data {
        guard let url = url else {
            throw URLError(.badURL)
        }
        let cacheKey = SDWebImageManager.shared.cacheKey(for: url)
        let chachedImage = SDImageCache.shared.imageFromCache(forKey: cacheKey)
        
        if let image = chachedImage, let imageData = image.jpegData(compressionQuality: 0.8) {
            return imageData
        } else {
            return try await networkManager.getImageData(url: url)
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
