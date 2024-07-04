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
    }
    
    override func tearDown() {
        coreDataManager = nil
        persistentContainer = nil
        subscriptions = nil
        
        super.tearDown()
    }
    
}
