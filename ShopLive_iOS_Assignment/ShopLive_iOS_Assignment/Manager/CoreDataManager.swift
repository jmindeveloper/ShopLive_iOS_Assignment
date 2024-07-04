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
    
    func saveFavoriteCharacter(entity: FavoriteMarvelCharacterEntity) {
        let favoriteCharacter = FavoriteMarvelCharacter(context: persistentContainer.viewContext)
        favoriteCharacter.id = entity.id
        favoriteCharacter.name = entity.name
        favoriteCharacter.characterDescription = entity.description
        favoriteCharacter.thumbnail = entity.thumbnail
        favoriteCharacter.date = Date()
        
        do {
            try persistentContainer.viewContext.save()
            var previousCharacterArray = favoriteCharacterPublisher.value
            
            previousCharacterArray.append(favoriteCharacter)
            if previousCharacterArray.count > 5 {
                // TODO: - 가장 오래된 카드 삭제
            } else {
                favoriteCharacterPublisher.send(previousCharacterArray)
            }
        } catch {
            persistentContainer.viewContext.rollback()
        }
    }
}
