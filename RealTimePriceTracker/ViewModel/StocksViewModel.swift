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
    
    func stock(for symbol: String) -> Stock? {
        stocks.first { $0.symbol == symbol }
    }
}
