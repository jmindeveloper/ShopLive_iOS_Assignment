//
//  NetworkCheck.swift
//  ShopLive_iOS_Assignment
//
//  Created by J_Min on 7/6/24.
//

import Foundation
import Network

final class NetworkCheck {
    static let shared = NetworkCheck()
    let monitor: NWPathMonitor = NWPathMonitor()
    var isConnectedPublisher = SLCurrentValueSubject<Bool>(true)
    
    private init() {
    
    }
    
    func startMonitoring() {
        monitor.start(queue: DispatchQueue.global())
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnectedPublisher.send(path.status == .satisfied)
            }
        }
    }
}
