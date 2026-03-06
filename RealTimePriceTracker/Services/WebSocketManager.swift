//
//  WebSocketManager.swift
//  RealTimePriceTracker
//
//  Created by Salman Qureshi on 3/6/26.
//

import Combine
import Foundation

@MainActor
final class WebSocketManager: ObservableObject {
    static let shared = WebSocketManager()
    
    @Published private(set) var isConnected = false
    let incomingMessages = PassthroughSubject<PriceUpdate, Never>()
    
    private let client = WebSocketClient()
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        client.receivedMessages
            .sink { [weak self] message in
                self?.incomingMessages.send(message)
            }
            .store(in: &cancellables)

        client.$isConnected
            .removeDuplicates()
            .sink { [weak self] connected in
                self?.isConnected = connected
            }
            .store(in: &cancellables)
    }
    
    func connect() {
        client.connect()
    }

    func disconnect() {
        client.disconnect()
    }
    
    func send(_ message: PriceUpdate) {
        client.send(message)
    }
}
