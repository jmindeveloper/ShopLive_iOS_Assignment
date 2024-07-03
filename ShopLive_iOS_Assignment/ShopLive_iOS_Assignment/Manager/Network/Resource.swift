//
//  Resource.swift
//  ShopLive_iOS_Assignment
//
//  Created by J_Min on 7/3/24.
//

import Foundation

struct Resource<T: Codable> {
    private var base: String
    private var path: String
    private var params: [String: String]
    
    var urlRequest: URLRequest? {
        guard var urlComponents = URLComponents(string: base + path) else { return nil }
        let queryItems = params.map {
            URLQueryItem(name: $0.key, value: $0.value)
        }
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else { return nil }
        let request = URLRequest(url: url)
        
        return request
    }
    
    init(
        base: String,
        path: String,
        params: [String : String]
    ) {
        self.base = base
        self.path = path
        self.params = params
    }
}
