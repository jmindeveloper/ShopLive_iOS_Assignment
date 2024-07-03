//
//  NetworkManager.swift
//  ShopLive_iOS_Assignment
//
//  Created by J_Min on 7/3/24.
//

import Foundation

final class NetworkManager {
    
    // MARK: - Properties
    private let session: URLSession
    
    init() {
        self.session = URLSession(configuration: .default)
    }
    
    // MARK: - Method
    func getMarvelCharacters() async {
        do {
            try session.data(for: )
        } catch {
            error.localizedDescription
        }
        
    }
}
