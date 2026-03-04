//
//  WebSocketClient.swift
//  RealTimePriceTracker
//
//  Created by Salman Qureshi on 3/5/26.
//
import Foundation
import Combine

final class WebSocketClient: ObservableObject {
    @Published private(set) var isConnected = false
    
    private let endpoint = URL(string: "wss://ws.postman-echo.com/raw")!
    private var webSocketTask: URLSessionWebSocketTask?
    private lazy var session = URLSession(configuration: .default)
    
    func connect() {
        guard webSocketTask == nil else { return }

        let task = session.webSocketTask(with: endpoint)
        webSocketTask = task
        task.resume()
        isConnected = true
    }

    func disconnect() {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        webSocketTask = nil
        isConnected = false
    }
}
