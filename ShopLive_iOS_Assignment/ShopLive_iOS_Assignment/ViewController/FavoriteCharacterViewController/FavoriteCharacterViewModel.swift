//
//  FavoriteCharacterViewModel.swift
//  ShopLive_iOS_Assignment
//
//  Created by J_Min on 7/4/24.
//

import Foundation
import Combine

protocol FavoriteCharacterViewModelProtocol {
    var favoriteMarvelCharacters: [FavoriteMarvelCharacter] { get set }
    var collectionViewUpdatePublisher: PassthroughSubject<Void, Never> { get }
    
    init(coreDataManager: CoreDataManagerProtocol)
    
    func deleteFavoriteMarvelCharacter(index: Int)
}

final class FavoriteCharacterViewModel: FavoriteCharacterViewModelProtocol {
    
    // MARK: - Properties
    private let coreDataManager: CoreDataManagerProtocol
    var favoriteMarvelCharacters: [FavoriteMarvelCharacter] = [] {
        didSet {
            collectionViewUpdatePublisher.send()
        }
    }
    let collectionViewUpdatePublisher = PassthroughSubject<Void, Never>()
    private var subscriptions = Set<AnyCancellable>()
    
    init(coreDataManager: CoreDataManagerProtocol) {
        self.coreDataManager = coreDataManager
        binding()
    }
    
    private func binding() {
        coreDataManager.favoriteCharacterPublisher
            .sink { [weak self] character in
                self?.favoriteMarvelCharacters = character
            }.store(in: &subscriptions)
    }
    
    func deleteFavoriteMarvelCharacter(index: Int) {
        let character = favoriteMarvelCharacters[index]
        coreDataManager.deleteFavoriteCharacter(character: character)
    }
}
