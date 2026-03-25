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
    @Published private var needsRefresh = false
    
    // Dedicated Serial Queue for thread safety
    private let syncQueue = DispatchQueue(label: "com.app.RealTimePriceTracker")
    private var lastFlashUpdate: [String: Date] = [:]
    
    private var stockMap: [String: Stock] = [:] // Symbol -> Current Array Index
    
    private let webSocketService: WebSocketServicing
    private let priceFeedEngine: PriceFeedGenerating
    private let tickerService: TickerServicing
    
    private var cancellables = Set<AnyCancellable>()
    
    init(dependencies: AppDependencies,
         initialStocks: [Stock] = Stock.initialStocks()) {
        self.webSocketService = dependencies.webSocketService
        self.priceFeedEngine = dependencies.priceFeedService
        self.tickerService = dependencies.tickerService
        
        let sorted = initialStocks.sorted { lhs, rhs in
            if lhs.price == rhs.price { return lhs.symbol < rhs.symbol }
            return lhs.price > rhs.price
        }
        self.stocks = sorted
        // Populate the map
        self.stockMap = Dictionary(uniqueKeysWithValues: sorted.map { ($0.symbol, $0) })
        
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
            .receive(on: syncQueue)
            .sink { [weak self] message in
                self?.apply(message)
            }
            .store(in: &cancellables)
        
        // Throttled UI Refresh, only sort/publish 10 times per second max
        $needsRefresh
            .filter { $0 }
            .throttle(for: .milliseconds(120), scheduler: RunLoop.main, latest: true)
            .sink { [weak self] _ in
                self?.refreshUI()
            }
            .store(in: &cancellables)
        
        tickerService.tickPublisher
            .receive(on: syncQueue)
            .sink { [weak self] _ in
                self?.generateUpdates()
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
        // O(1) Lookup
        guard var stock = stockMap[message.symbol] else { return }
        
        let oldPrice = stock.price
        stock.previousPrice = oldPrice
        stock.price = message.price
        stock.changePercent = message.changePercent
        stock.flashDirection = message.price > oldPrice ? .up : (message.price < oldPrice ? .down : nil)
        
        // Update
        stockMap[message.symbol] = stock
        
        // Record the update time instead of queuing a closure
        lastFlashUpdate[message.symbol] = Date()
        
        // Signal that a refresh is needed without blocking the background thread
        DispatchQueue.main.async { self.needsRefresh = true }
    }
    
    private func refreshSortedList() {
        self.stocks = stockMap.values.sorted {
            if $0.price == $1.price { return $0.symbol < $1.symbol }
            return $0.price > $1.price
        }
    }
    
    private func refreshUI() {
        syncQueue.async { [weak self] in
            guard let self = self else { return }
            let now = Date()
            
            // Clear expired flashes and PRUNE the dictionary to save memory
            let expiredSymbols = lastFlashUpdate.filter { now.timeIntervalSince($0.value) > 0.8 }.keys

            for symbol in expiredSymbols {
                self.stockMap[symbol]?.flashDirection = nil
                self.lastFlashUpdate.removeValue(forKey: symbol)
            }
            
            let sorted = self.stockMap.values.sorted {
                $0.price == $1.price ? $0.symbol < $1.symbol : $0.price > $1.price
            }
            
            DispatchQueue.main.async {
                // Update the UI
                self.stocks = sorted
                // Set to false AFTER the UI has the latest data
                self.needsRefresh = false
            }
        }
    }
    
    // Thread-safe getter
    func stock(for symbol: String) -> Stock? {
        syncQueue.sync { stockMap[symbol] }
    }
    
    private func generateUpdates() {
        stockMap.values.forEach { stock in
            let update = priceFeedEngine.nextUpdate(for: stock)
            webSocketService.send(update)
        }
    }
}
