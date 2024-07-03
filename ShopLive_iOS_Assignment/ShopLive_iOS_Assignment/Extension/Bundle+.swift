//
//  Bundle+.swift
//  ShopLive_iOS_Assignment
//
//  Created by J_Min on 7/4/24.
//

import Foundation

extension Bundle {
    var PUBLIC_KEY: String? {
        infoDictionary?["PUBLIC_KEY"] as? String
    }
    
    var PRIVATE_KEY: String? {
        infoDictionary?["PRIVATE_KEY"] as? String
    }
}
