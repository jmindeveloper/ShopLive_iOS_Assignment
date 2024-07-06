//
//  CoreDataManager.swift
//  ShopLive_iOS_Assignment
//
//  Created by J_Min on 7/4/24.
//

import Foundation
import CoreData

protocol CoreDataManagerProtocol {
    var favoriteCharacterPublisher: SLCurrentValueSubject<[FavoriteMarvelCharacter]> { get }
    var errorPublisher: SLPassthroughSubject<Error> { get }
    
    init(persistentContainer: NSPersistentContainer?)
    
    func getFavoriteCharacter()
    func saveFavoriteCharacter(entity: FavoriteMarvelCharacterEntity)
    func deleteFavoriteCharacter(character: FavoriteMarvelCharacter)
}

final class CoreDataManager: CoreDataManagerProtocol {
    
    // MARK: - Properties
    private let entityName = "FavoriteMarvelCharacter"
    private let persistentContainer: NSPersistentContainer
    let favoriteCharacterPublisher = SLCurrentValueSubject<[FavoriteMarvelCharacter]>([])
    let errorPublisher = SLPassthroughSubject<Error>()
    
    init(persistentContainer: NSPersistentContainer? = nil) {
        if let container = persistentContainer {
            self.persistentContainer = container
        } else {
            self.persistentContainer = NSPersistentContainer(name: entityName)
            self.persistentContainer.loadPersistentStores { _, error in
                if let error = error {
                    fatalError(error.localizedDescription)
                }
            }
        }
    }
    
    func getFavoriteCharacter() {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        
        do {
            let favoriteCharacters = try persistentContainer.viewContext.fetch(fetchRequest) as? [FavoriteMarvelCharacter] ?? []
            favoriteCharacterPublisher.send(favoriteCharacters)
        } catch {
            errorPublisher.send(error)
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
            errorPublisher.send(error)
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
            errorPublisher.send(error)
            persistentContainer.viewContext.rollback()
        }
    }
    
    private func removeOldestCharacter(characters: [FavoriteMarvelCharacter]) throws -> [FavoriteMarvelCharacter] {
        var characters = characters
        let oldestCharacter = characters.min {
            $0.date ?? Date() < $1.date ?? Date()
        }
        
        if let oldestCharacter = oldestCharacter {
            persistentContainer.viewContext.delete(oldestCharacter)
            try persistentContainer.viewContext.save()
            characters.removeAll { $0.id == oldestCharacter.id }
        }
        
        return characters
    }
}
