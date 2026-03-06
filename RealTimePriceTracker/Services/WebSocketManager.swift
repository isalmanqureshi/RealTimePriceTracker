//
//  WebSocketManager.swift
//  RealTimePriceTracker
//
//  Created by Salman Qureshi on 3/6/26.
//

import Combine
import Foundation

protocol WebSocketServicing {
    var connectionPublisher: AnyPublisher<Bool, Never> { get }
    var messagePublisher: AnyPublisher<StockMessage, Never> { get }

    func connect()
    func disconnect()
    func send(_ message: PriceUpdate)
}

final class WebSocketManager: WebSocketServicing {

    let client: WebSocketClient
    
    init(client: WebSocketClient = WebSocketClient()) {
        self.client = client
    }
    
    var connectionPublisher: AnyPublisher<Bool, Never> {
        client.connectionPublisher
    }

    var messagePublisher: AnyPublisher<StockMessage, Never> {
        client.messagePublisher
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
