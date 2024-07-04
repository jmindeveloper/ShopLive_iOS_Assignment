//
//  CoreDataManager.swift
//  ShopLive_iOS_Assignment
//
//  Created by J_Min on 7/4/24.
//

import Foundation
import CoreData
import Combine

final class CoreDataManager {
    
    // MARK: - Properties
    private let entityName = "FavoriteMarvelCharacter"
    private let persistentContainer: NSPersistentContainer
    let favoriteCharacterPublisher = CurrentValueSubject<[FavoriteMarvelCharacter], Never>([] )
    
    init() {
        persistentContainer = NSPersistentContainer(name: entityName)
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    func getFavoriteCharacter() {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        
        do {
            let favoriteCharacters = try persistentContainer.viewContext.fetch(fetchRequest) as? [FavoriteMarvelCharacter] ?? []
            favoriteCharacterPublisher.send(favoriteCharacters)
        } catch {
            print(error.localizedDescription)
        }
    }
}
