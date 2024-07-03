//
//  Character.swift
//  ShopLive_iOS_Assignment
//
//  Created by J_Min on 7/3/24.
//

import Foundation

struct MarvelCharacterAPIResult: Codable {
    let data: MarvelCharacterAPIData
}

struct MarvelCharacterAPIData: Codable {
    let count: Int
    let results: [Character]
}

/// 실제 사용하는 캐릭터 모델
struct Character: Codable {
    let id: String
    let name: String
    let description: String
    let thumbnail: Thumbnail
}

struct Thumbnail: Codable {
    let path: String
    let `extension`: String
}

