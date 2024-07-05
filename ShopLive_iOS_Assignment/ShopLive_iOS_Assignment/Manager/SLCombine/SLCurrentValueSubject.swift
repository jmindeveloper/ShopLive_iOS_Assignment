//
//  SLCurrentValueSubject.swift
//  ShopLive_iOS_Assignment
//
//  Created by J_Min on 7/5/24.
//

import Foundation

class SLCurrentValueSubject<Output> {
    typealias Subscriber = (Output) -> Void
    
    private var subscribers: [Subscriber] = []
    private var currentValue: Output
    
    init(_ value: Output) {
        self.currentValue = value
    }
    
    var value: Output {
        get {
            return currentValue
        }
        set {
            currentValue = newValue
            send(newValue)
        }
    }
    
    func subscribe(_ subscriber: @escaping Subscriber) {
        subscribers.append(subscriber)
        subscriber(currentValue)
    }
    
    func send(_ value: Output) {
        currentValue = value
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
