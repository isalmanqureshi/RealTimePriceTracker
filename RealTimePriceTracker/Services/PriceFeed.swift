//
//  PriceFeed.swift
//  RealTimePriceTracker
//
//  Created by Salman Qureshi on 3/6/26.
//

import Foundation

struct PriceFeedEngine {
    func nextUpdate(for stock: Stock) -> PriceUpdate {
        let direction = Bool.random() ? 1.0 : -1.0
        let volatility = Double.random(in: 0.002...0.025)
        let rawChangePercent = direction * volatility * 100
        let nextPrice = max(1.0, stock.price * (1 + (rawChangePercent / 100)))

        return PriceUpdate(
            symbol: stock.symbol,
            price: (nextPrice * 100).rounded() / 100,
            changePercent: (rawChangePercent * 100).rounded() / 100
        )
    }
}
