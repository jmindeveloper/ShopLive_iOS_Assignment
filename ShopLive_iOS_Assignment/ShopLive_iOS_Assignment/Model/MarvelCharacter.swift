//
//  MarvelCharacter.swift
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
    let results: [MarvelCharacter]
}

/// 실제 사용하는 캐릭터 모델
struct MarvelCharacter: Codable {
    let id: String
    let name: String
    let description: String
    let thumbnail: Thumbnail
}

struct Thumbnail: Codable {
    let path: String
    let `extension`: String
}

let characterMockData = [
    MarvelCharacter(id: "1", name: "아이언맨", description: "짱쌘 아이언맨", thumbnail: Thumbnail(path: "mock_image", extension: "")),
    MarvelCharacter(id: "1", name: "스파이더맨", description: "우리들의 친절한 이웃 스파이더맨", thumbnail: Thumbnail(path: "mock_image", extension: "")),
    MarvelCharacter(id: "1", name: "캡틴아메리카", description: "블루스컬", thumbnail: Thumbnail(path: "mock_image", extension: "")),
    MarvelCharacter(id: "1", name: "토르", description: "망치의 신", thumbnail: Thumbnail(path: "mock_image", extension: "")),
]
