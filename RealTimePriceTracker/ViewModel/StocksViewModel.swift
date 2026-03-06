//
//  StocksViewModel.swift
//  RealTimePriceTracker
//
//  Created by Salman Qureshi on 3/5/26.
//
import Foundation
import Combine

final class StocksViewModel: ObservableObject {
    @Published private(set) var stocks: [Stock]
    @Published private(set) var isConnected = false
    @Published private(set) var isFeedRunning = false
    
    private let webSocketService: WebSocketServicing
    private let priceFeedEngine: PriceFeedGenerating
    private let tickerService: TickerServicing
    
    private var cancellables = Set<AnyCancellable>()
    
    init(dependencies: AppDependencies,
        initialStocks: [Stock] = Stock.initialStocks()) {
        self.webSocketService = dependencies.webSocketService
        self.priceFeedEngine = dependencies.priceFeedService
        self.tickerService = dependencies.tickerService
        self.stocks = initialStocks.sorted { lhs, rhs in
            if lhs.price == rhs.price { return lhs.symbol < rhs.symbol }
            return lhs.price > rhs.price
        }
        
        bind()
        connectIfNeeded()
    }
    
    func connectIfNeeded() {
        webSocketService.connect()
    }
    
    func toggleFeed() {
        isFeedRunning ? stopFeed() : startFeed()
    }
    
    private func bind() {
        webSocketService.connectionPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$isConnected)
        
        webSocketService.messagePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.apply(message)
            }
            .store(in: &cancellables)
        
        tickerService.tickPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.stocks.forEach { stock in
                    let update = self.priceFeedEngine.nextUpdate(for: stock)
                    self.webSocketService.send(update)
                }
            }
            .store(in: &cancellables)
    }
    
    func startFeed() {
        guard !isFeedRunning else { return }
        connectIfNeeded()
        isFeedRunning = true
        tickerService.start(interval: 2.0)
    }
    
    func stopFeed() {
        tickerService.stop()
        isFeedRunning = false
    }
    
    private func apply(_ message: PriceUpdate) {
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
