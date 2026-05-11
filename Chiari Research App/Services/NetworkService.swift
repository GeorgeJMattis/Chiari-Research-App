//
//  NetworkService.swift
//  Chiari Research App
//
//  Created by George Mattis on 4/17/26.
//

import Foundation
import Network

class NetworkService {
    static let shared = NetworkService()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.chiari.networkMonitor")
    private(set) var isConnected: Bool = false

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
        }
        monitor.start(queue: queue)
    }
}
