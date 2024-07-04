//
//  FavoriteMarvelCharacter+CoreDataClass.swift
//  ShopLive_iOS_Assignment
//
//  Created by J_Min on 7/4/24.
//
//

import Foundation
import CoreData

@objc(FavoriteMarvelCharacter)
public class FavoriteMarvelCharacter: NSManagedObject {

}

struct FavoriteMarvelCharacterEntity {
    let id: Int64
    let name: String
    let description: String
    let date: Date
    let thumbnail: Data
}
