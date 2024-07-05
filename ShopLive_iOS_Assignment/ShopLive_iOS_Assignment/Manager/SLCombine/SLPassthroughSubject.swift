//
//  SLPassthroughSubject.swift
//  ShopLive_iOS_Assignment
//
//  Created by J_Min on 7/5/24.
//

import Foundation

class SLPassthroughSubject<Output> {
    typealias Subscriber = (Output) -> Void
    
    // 구독된 Subscriber
    private var subscribers: [Subscriber] = []
    
    func subscribe(_ subscriber: @escaping Subscriber) {
        subscribers.append(subscriber)
    }
    
    func send(_ value: Output) {
        for subscriber in subscribers {
            subscriber(value)
        }
    }
    
    @discardableResult
    func sink(_ receiveValue: @escaping (Output) -> Void) -> SLAnyCancellable {
        let subscriber = SLSubscriber(receiveValue)
        subscribe { value in
            subscriber.receive(value)
        }
        
        let cancellable = SLAnyCancellable { [weak self] in
            self?.subscribers.removeAll { $0 as AnyObject === subscriber }
            subscriber.cancel()
        }
        
        return cancellable
    }
}
