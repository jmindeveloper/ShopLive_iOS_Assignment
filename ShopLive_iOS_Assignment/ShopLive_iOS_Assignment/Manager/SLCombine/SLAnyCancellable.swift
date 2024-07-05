//
//  SLAnyCancellable.swift
//  ShopLive_iOS_Assignment
//
//  Created by J_Min on 7/5/24.
//

import Foundation

class SLAnyCancellable {
    private let cancelAction: () -> Void
    private var isCancelled = false
    
    init(_ cancelAction: @escaping () -> Void) {
        self.cancelAction = cancelAction
    }
    
    func cancel() {
        guard !isCancelled else { return }
        isCancelled = true
        cancelAction()
    }
    
    func store(in set: inout Set<SLAnyCancellable>) {
        set.insert(self)
    }
}

extension SLAnyCancellable: Hashable {
    static func == (lhs: SLAnyCancellable, rhs: SLAnyCancellable) -> Bool {
        return lhs === rhs
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
