//
//  WebSocketClient.swift
//  RealTimePriceTracker
//
//  Created by Salman Qureshi on 3/5/26.
//
import Foundation
import Combine

final class WebSocketClient {
    private let endpoint = URL(string: "wss://ws.postman-echo.com/raw")!
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    private var webSocketTask: URLSessionWebSocketTask?
    private lazy var session = URLSession(configuration: .default)
    
    private let connection = CurrentValueSubject<Bool, Never>(false)
    private let receivedMessage = PassthroughSubject<PriceUpdate, Never>()
    
    var connectionPublisher: AnyPublisher<Bool, Never> {
        connection.removeDuplicates().eraseToAnyPublisher()
    }
    
    var messagePublisher: AnyPublisher<PriceUpdate, Never> {
        receivedMessage.eraseToAnyPublisher()
    }
    
    func connect() {
        guard webSocketTask == nil else { return }
        
        let task = session.webSocketTask(with: endpoint)
        webSocketTask = task
        task.resume()
        connection.send(true)
        receiveNext()
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        webSocketTask = nil
        connection.send(false)
    }
    
    func send(_ message: PriceUpdate) {
        guard let webSocketTask else { return }
        
        do {
            let data = try encoder.encode(message)
            let text = String(decoding: data, as: UTF8.self)
            webSocketTask.send(.string(text)) { [weak self] error in
                guard let self else { return }
                if error != nil {
                    Task { @MainActor in
                        self.connection.send(false)
                        self.webSocketTask = nil
                    }
                }
            }
        } catch {
            self.connection.send(false)
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
                   let decoded = try? self.decoder.decode(PriceUpdate.self, from: data) {
                        self.receivedMessage.send(decoded)
                    }
                
                self.receiveNext()
                
            case .failure:
                self.connection.send(false)
                self.webSocketTask = nil
            }
        }
    }
}
