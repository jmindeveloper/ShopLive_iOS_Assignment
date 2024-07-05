//
//  Operators.swift
//  ShopLive_iOS_Assignment
//
//  Created by J_Min on 7/5/24.
//

import Foundation

extension SLCurrentValueSubject {
    func debounce(for interval: TimeInterval, queue: DispatchQueue = .main) -> SLCurrentValueSubject<Output> {
        let debouncedPublisher = SLCurrentValueSubject<Output>(value)
        var workItem: DispatchWorkItem?
        
        self.subscribe { value in
            workItem?.cancel()
            workItem = DispatchWorkItem {
                debouncedPublisher.send(value)
            }
            queue.asyncAfter(deadline: .now() + interval, execute: workItem!)
        }
        
        return debouncedPublisher
    }
    
    func receive(on queue: DispatchQueue) -> SLCurrentValueSubject<Output> {
        let receivedPublisher = SLCurrentValueSubject<Output>(value)
        
        self.subscribe { value in
            queue.async {
                receivedPublisher.send(value)
            }
        }
        
        return receivedPublisher
    }
}

extension SLPassthroughSubject {
    func debounce(for interval: TimeInterval, queue: DispatchQueue = .main) -> SLPassthroughSubject<Output> {
        let debouncedPublisher = SLPassthroughSubject<Output>()
        var workItem: DispatchWorkItem?
        
        self.subscribe { value in
            workItem?.cancel()
            workItem = DispatchWorkItem {
                debouncedPublisher.send(value)
            }
            queue.asyncAfter(deadline: .now() + interval, execute: workItem!)
        }
        
        return debouncedPublisher
    }
    
    func receive(on queue: DispatchQueue) -> SLPassthroughSubject<Output> {
        let receivedPublisher = SLPassthroughSubject<Output>()
        
        self.subscribe { value in
            queue.async {
                receivedPublisher.send(value)
            }
        }
        
        return receivedPublisher
    }
}
