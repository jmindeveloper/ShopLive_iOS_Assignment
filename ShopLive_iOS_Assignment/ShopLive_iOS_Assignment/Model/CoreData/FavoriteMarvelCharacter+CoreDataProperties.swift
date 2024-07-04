//
//  FavoriteMarvelCharacter+CoreDataProperties.swift
//  ShopLive_iOS_Assignment
//
//  Created by J_Min on 7/4/24.
//
//

import Foundation
import CoreData


extension FavoriteMarvelCharacter {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoriteMarvelCharacter> {
        return NSFetchRequest<FavoriteMarvelCharacter>(entityName: "FavoriteMarvelCharacter")
    }

    @NSManaged public var id: Int64
    @NSManaged public var name: String?
    @NSManaged public var characterDescription: String?
    @NSManaged public var date: Date?
    @NSManaged public var thumbnail: Data?

}

extension FavoriteMarvelCharacter : Identifiable {

}
