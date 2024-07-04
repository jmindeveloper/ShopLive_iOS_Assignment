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
        favoriteCharacter.date = entity.date
        
        do {
            try persistentContainer.viewContext.save()
            var previousCharacterArray = favoriteCharacterPublisher.value
            
            previousCharacterArray.append(favoriteCharacter)
            if previousCharacterArray.count > 5 {
                favoriteCharacterPublisher.send(try removeOldestCharacter(characters: previousCharacterArray))
            } else {
                favoriteCharacterPublisher.send(previousCharacterArray)
            }
        } catch {
            persistentContainer.viewContext.rollback()
        }
    }
    
    func deleteFavoriteCharacter(character: FavoriteMarvelCharacter) {
        persistentContainer.viewContext.delete(character)
        
        do {
            try persistentContainer.viewContext.save()
            var previousCharacterArray = favoriteCharacterPublisher.value
            previousCharacterArray.removeAll { $0.id == character.id }
            favoriteCharacterPublisher.send(previousCharacterArray)
        } catch {
            persistentContainer.viewContext.rollback()
        }
    }
    
    private func removeOldestCharacter(characters: [FavoriteMarvelCharacter]) throws -> [FavoriteMarvelCharacter] {
        var characters = characters
        let oldestCharacter = characters.min {
            $0.date ?? Date() < $1.date ?? Date()
        }
        
        if let oldestCharacter = oldestCharacter {
            characters.removeAll { $0.id == oldestCharacter.id }
            persistentContainer.viewContext.delete(oldestCharacter)
            try persistentContainer.viewContext.save()
        }
        
        return characters
    }
}
