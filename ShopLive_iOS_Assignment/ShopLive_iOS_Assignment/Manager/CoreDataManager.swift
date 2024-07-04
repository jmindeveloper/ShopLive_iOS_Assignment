//
//  CoreDataManager.swift
//  ShopLive_iOS_Assignment
//
//  Created by J_Min on 7/4/24.
//

import Foundation
import CoreData

final class CoreDataManager {
    
    // MARK: - Properties
    private let entityName = "FavoriteMarvelCharacter"
    private let persistentContainer: NSPersistentContainer
    
    init() {
        persistentContainer = NSPersistentContainer(name: entityName)
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    
}
