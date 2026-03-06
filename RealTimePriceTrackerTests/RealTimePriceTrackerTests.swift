//
//  RealTimePriceTrackerTests.swift
//  RealTimePriceTrackerTests
//
//  Created by Salman Qureshi on 3/4/26.
//

import XCTest
import Foundation
import Combine
@testable import RealTimePriceTracker

final class RealTimePriceTrackerTests: XCTestCase {
    
    @MainActor
    func testTrackedSymbolsExactCountAndValues() {
        XCTAssertEqual(Stock.trackedSymbols, [
            "AAPL", "GOOG", "TSLA", "AMZN", "MSFT", "NVDA", "META", "AMD", "NFLX", "AVGO",
            "ADBE", "PYPL", "CRM", "ORCL", "CSCO", "IBM", "QCOM", "TXN", "AMAT", "MU",
            "LRCX", "NOW", "INTU", "ISRG", "SPOT"
        ])
    }
    
    @MainActor
    func testTickSendsUpdatesForAllSymbols() async {
        let websocket = MockWebSocketService()
        let ticker = MockTickerService()
        let generator = MockPriceFeedGenerator()
        let dependencies = AppDependencies(webSocketService: websocket, tickerService: ticker, priceFeedService: generator)
        let vm = StocksViewModel(dependencies: dependencies, initialStocks: [
            Stock(symbol: "AAPL", price: 100, changePercent: 0, previousPrice: 100, flashDirection: nil),
            Stock(symbol: "MSFT", price: 200, changePercent: 0, previousPrice: 200, flashDirection: nil)
        ])
        
        vm.startFeed()
        ticker.sendTick()
        await drainMainQueue()
        
        XCTAssertEqual(websocket.sentMessages.count, 2)
        XCTAssertEqual(Set(websocket.sentMessages.map(\.symbol)), ["AAPL", "MSFT"])
    }

    @MainActor
    func testInboundMessageUpdatesAndSortsDescending() async {
        let websocket = MockWebSocketService()
        let ticker = MockTickerService()
        let generator = MockPriceFeedGenerator()
        let dependencies = AppDependencies(webSocketService: websocket, tickerService: ticker, priceFeedService: generator)
        let vm = StocksViewModel(dependencies: dependencies, initialStocks: [
            Stock(symbol: "AAPL", price: 100, changePercent: 0, previousPrice: 100, flashDirection: nil),
            Stock(symbol: "MSFT", price: 200, changePercent: 0, previousPrice: 200, flashDirection: nil)
        ])

        websocket.sendIncoming(.init(symbol: "AAPL", price: 300, changePercent: 2.0))
        await drainMainQueue()

        XCTAssertEqual(vm.stocks.first?.symbol, "AAPL")
        XCTAssertEqual(vm.stocks.first?.previousPrice, 100)
        XCTAssertEqual(vm.stocks.first?.price, 300)
    }
    
    private func drainMainQueue() async {
         await withCheckedContinuation { continuation in
             DispatchQueue.main.async {
                 continuation.resume()
             }
         }
     }
}

private final class MockWebSocketService: WebSocketServicing {
    private let connection = CurrentValueSubject<Bool, Never>(true)
    private let incomingMessage = PassthroughSubject<PriceUpdate, Never>()

    private(set) var sentMessages: [PriceUpdate] = []

    var connectionPublisher: AnyPublisher<Bool, Never> {
        connection.eraseToAnyPublisher()
    }

    var messagePublisher: AnyPublisher<PriceUpdate, Never> {
        incomingMessage.eraseToAnyPublisher()
    }

    func connect() {
        connection.send(true)
    }

    func disconnect() {
        connection.send(false)
    }

    func send(_ message: StockMessage) {
        sentMessages.append(message)
    }

    func sendIncoming(_ message: StockMessage) {
        incomingMessage.send(message)
    }
}

private struct MockPriceFeedGenerator: PriceFeedGenerating {
    func nextUpdate(for stock: Stock) -> PriceUpdate {
        PriceUpdate(symbol: stock.symbol, price: stock.price + 1, changePercent: 1.0)
    }
}

private final class MockTickerService: TickerServicing {
    private let tick = PassthroughSubject<Date, Never>()

    var tickPublisher: AnyPublisher<Date, Never> {
        tick.eraseToAnyPublisher()
    }

    func start(interval: TimeInterval) {}
    func stop() {}

    func sendTick() {
        tick.send(Date())
    }
}
