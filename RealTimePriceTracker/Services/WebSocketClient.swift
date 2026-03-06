//
//  WebSocketClient.swift
//  RealTimePriceTracker
//
//  Created by Salman Qureshi on 3/5/26.
//
import Foundation
import Combine

@MainActor
final class WebSocketClient: ObservableObject {
    @Published private(set) var isConnected = false
    
    private let endpoint = URL(string: "wss://ws.postman-echo.com/raw")!
    private var webSocketTask: URLSessionWebSocketTask?
    private lazy var session = URLSession(configuration: .default)
    
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    let receivedMessages = PassthroughSubject<StockMessage, Never>()
    
    func connect() {
        guard webSocketTask == nil else { return }

        let task = session.webSocketTask(with: endpoint)
        webSocketTask = task
        task.resume()
        isConnected = true
        receiveNext()
    }

    func disconnect() {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        webSocketTask = nil
        isConnected = false
    }
    
    func send(_ message: StockMessage) {
        guard let webSocketTask else { return }

        do {
            let data = try encoder.encode(message)
            let text = String(decoding: data, as: UTF8.self)
            webSocketTask.send(.string(text)) { [weak self] error in
                guard let self else { return }
                if error != nil {
                    Task { @MainActor in
                        self.isConnected = false
                        self.webSocketTask = nil
                    }
                }
            }
        } catch {
            isConnected = false
        }
    }
    
    private func receiveNext() {
        webSocketTask?.receive { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let payload):
                let data: Data?
                switch payload {
                case .string(let string):
                    data = string.data(using: .utf8)
                case .data(let incomingData):
                    data = incomingData
                @unknown default:
                    data = nil
                }

                if let data,
                   let decoded = try? self.decoder.decode(StockMessage.self, from: data) {
                    Task { @MainActor in
                        self.receivedMessages.send(decoded)
                    }
                }

                self.receiveNext()

            case .failure:
                Task { @MainActor in
                    self.isConnected = false
                    self.webSocketTask = nil
                }
            }
        }
    }
}
