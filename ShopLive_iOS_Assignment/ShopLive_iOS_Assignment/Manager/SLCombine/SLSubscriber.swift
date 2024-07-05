//
//  SLSubscriber.swift
//  ShopLive_iOS_Assignment
//
//  Created by J_Min on 7/5/24.
//

import Foundation

class SLSubscriber<Input> {
    private let receiveValue: (Input) -> Void
    private var isCancelled = false
    
    init(_ receiveValue: @escaping (Input) -> Void) {
        self.receiveValue = receiveValue
    }
    
    func receive(_ value: Input) {
        guard !isCancelled else { return }
        receiveValue(value)
    }
    
    func cancel() {
        isCancelled = true
    }
}
