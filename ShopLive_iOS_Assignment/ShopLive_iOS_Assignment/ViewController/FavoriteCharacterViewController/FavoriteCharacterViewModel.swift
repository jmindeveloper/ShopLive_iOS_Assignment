//
//  FavoriteCharacterViewModel.swift
//  ShopLive_iOS_Assignment
//
//  Created by J_Min on 7/4/24.
//

import Foundation

protocol FavoriteCharacterViewModelProtocol {
    var favoriteMarvelCharacters: [FavoriteMarvelCharacter] { get set }
    var collectionViewUpdatePublisher: SLPassthroughSubject<Void> { get }
    var emptyFavoriteMarvelCharacterPublisher: SLCurrentValueSubject<Bool> { get }
    var errorPublisher: SLPassthroughSubject<Error> { get }
    
    init(coreDataManager: CoreDataManagerProtocol)
    
    func deleteFavoriteMarvelCharacter(index: Int)
}

final class FavoriteCharacterViewModel: FavoriteCharacterViewModelProtocol {
    
    // MARK: - Properties
    private let coreDataManager: CoreDataManagerProtocol
    var favoriteMarvelCharacters: [FavoriteMarvelCharacter] = [] {
        didSet {
            collectionViewUpdatePublisher.send(Void())
        }
    }
    let collectionViewUpdatePublisher = SLPassthroughSubject<Void>()
    let emptyFavoriteMarvelCharacterPublisher = SLCurrentValueSubject<Bool>(true)
    let errorPublisher = SLPassthroughSubject<Error>()
    private var subscriptions = Set<SLAnyCancellable>()
    
    init(coreDataManager: CoreDataManagerProtocol) {
        self.coreDataManager = coreDataManager
        binding()
    }
    
    private func binding() {
        coreDataManager.favoriteCharacterPublisher
            .sink { [weak self] character in
                guard let self = self else { return }
                if character.isEmpty != emptyFavoriteMarvelCharacterPublisher.value {
                    emptyFavoriteMarvelCharacterPublisher.send(character.isEmpty)
                }
                
                favoriteMarvelCharacters = character
            }.store(in: &subscriptions)
        
        coreDataManager.errorPublisher
            .sink { [weak self] error in
                self?.errorPublisher.send(error)
            }.store(in: &subscriptions)
    }
    
    func deleteFavoriteMarvelCharacter(index: Int) {
        let character = favoriteMarvelCharacters[index]
        coreDataManager.deleteFavoriteCharacter(character: character)
    }
}
