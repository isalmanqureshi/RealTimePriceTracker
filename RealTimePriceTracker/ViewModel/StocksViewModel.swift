//
//  StocksViewModel.swift
//  RealTimePriceTracker
//
//  Created by Salman Qureshi on 3/5/26.
//
import Foundation
import Combine

final class StocksViewModel: ObservableObject {
    @Published private(set) var stocks: [Stock] = Stock.initialStocks()
    @Published private(set) var isConnected = false
    
    private let webSocketManager: WebSocketManager
    private let feedEngine: PriceFeedEngine
    private var timerCancellable: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    
    init(webSocketManager: WebSocketManager = .shared, feedEngine: PriceFeedEngine = PriceFeedEngine()) {
        self.webSocketManager = webSocketManager
        self.feedEngine = feedEngine
        bind()
        connectIfNeeded()
    }
    
    func connectIfNeeded() {
        webSocketManager.connect()
    }
    
    func startFeed() {
        guard timerCancellable == nil else { return }
        connectIfNeeded()

        timerCancellable = Timer.publish(every: 1.6, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                self.stocks.forEach { stock in
                    let update = self.feedEngine.nextUpdate(for: stock)
                    self.webSocketManager.send(update)
                }
            }
    }
    
    private func bind() {
        webSocketManager.incomingMessages
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.apply(message)
            }
            .store(in: &cancellables)

        webSocketManager.$isConnected
            .receive(on: DispatchQueue.main)
            .assign(to: &$isConnected)
    }
    
    func stopFeed() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }
    
    private func apply(_ message: StockMessage) {
        guard let index = stocks.firstIndex(where: { $0.symbol == message.symbol }) else { return }

        let oldPrice = stocks[index].price
        let nextDirection: Stock.FlashDirection? = message.price > oldPrice ? .up : (message.price < oldPrice ? .down : nil)

        stocks[index].previousPrice = oldPrice
        stocks[index].price = message.price
        stocks[index].changePercent = message.changePercent
        stocks[index].flashDirection = nextDirection

        stocks.sort {
            if $0.price == $1.price { return $0.symbol < $1.symbol }
            return $0.price > $1.price
        }

        let symbol = message.symbol
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            guard let self else { return }
            guard let currentIndex = self.stocks.firstIndex(where: { $0.symbol == symbol }) else { return }
            self.stocks[currentIndex].flashDirection = nil
        }
    }
    
    func stock(for symbol: String) -> Stock? {
        stocks.first { $0.symbol == symbol }
    }
}
