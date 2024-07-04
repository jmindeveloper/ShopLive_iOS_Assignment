//
//  ShopLive_iOS_Assignment_CoreDataManagerTests.swift
//  ShopLive_iOS_AssignmentTests
//
//  Created by J_Min on 7/4/24.
//

import XCTest
import CoreData
import Combine
@testable import ShopLive_iOS_Assignment

final class ShopLive_iOS_Assignment_CoreDataManagerTests: XCTestCase {
    var coreDataManager: CoreDataManager!
    var persistentContainer: NSPersistentContainer!
    private var subscriptions: Set<AnyCancellable>!
    var characters: [FavoriteMarvelCharacterEntity]!
    
    override func setUp() {
        super.setUp()
        subscriptions = Set<AnyCancellable>()
        persistentContainer = NSPersistentContainer(name: "FavoriteMarvelCharacter")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        persistentContainer.persistentStoreDescriptions = [description]
        persistentContainer.loadPersistentStores { _, error in
            XCTAssertNil(error)
        }
        
        coreDataManager = CoreDataManager(persistentContainer: persistentContainer)
        
        characters = characterMockData.map { character in
            FavoriteMarvelCharacterEntity(
                id: Int64(character.id),
                name: character.name,
                description: character.description,
                date: Date(),
                thumbnail: Data()
            )
        }
    }
    
    override func tearDown() {
        coreDataManager = nil
        persistentContainer = nil
        subscriptions = nil
        
        super.tearDown()
    }
    
    func test_getFavoriteCharacterTest() {
        // Given
        let entity = characters.first!
        coreDataManager.saveFavoriteCharacter(entity: entity)
        
        //When
        coreDataManager.getFavoriteCharacter()
        
        //Then
        coreDataManager.favoriteCharacterPublisher
            .sink { characters in
                XCTAssertEqual(characters.count, 1)
                XCTAssertEqual(characters.first?.id, 1)
            }.store(in: &subscriptions)
    }
}
