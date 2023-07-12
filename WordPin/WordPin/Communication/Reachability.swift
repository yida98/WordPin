//
//  Reachability.swift
//  WordPin
//
//  Created by Yida Zhang on 7/12/23.
//

import Foundation
import Network

public class NetworkMonitor: ObservableObject {
    @Published var connected: Bool = false
    let queue = DispatchQueue(label: "NetworkMonitor")
    let monitor = NWPathMonitor()
    
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.connected = path.status == .satisfied
        }
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
}
