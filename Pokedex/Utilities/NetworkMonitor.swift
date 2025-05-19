//
//  NetworkMonitor.swift
//  Pokedex
//
//  Created by Jonathan Rajya on 19/05/2025.
//
import Network
import Combine
import SwiftUI

@Observable
class NetworkMonitor {
    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "NetworkMonitor")

    var isConnected: Bool = true
    var connectionType: NWInterface.InterfaceType?

    init() {
        monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async { // Ensure UI updates are on main thread
                self?.isConnected = path.status == .satisfied
                self?.connectionType = NWInterface.InterfaceType.allCases.first(where: path.usesInterfaceType)
                
                // Log status changes for debugging
                // print("Network status updated: Connected - \(self?.isConnected ?? false), Type - \(self?.connectionType?.description ?? "Unknown")")
            }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}

extension NWInterface.InterfaceType {
    var description: String {
        switch self {
        case .other: return "Other"
        case .wifi: return "Wi-Fi"
        case .cellular: return "Cellular"
        case .loopback: return "Loopback"
        case .wiredEthernet: return "Wired Ethernet"
        @unknown default: return "Unknown"
        }
    }
}
