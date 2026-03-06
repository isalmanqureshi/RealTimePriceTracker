//
//  Stocks.swift
//  RealTimePriceTracker
//
//  Created by Salman Qureshi on 3/4/26.
//
import Foundation
import SwiftUI

struct Stock: Identifiable, Hashable {
    
    let symbol: String
    var price: Double
    var changePercent: Double
    var previousPrice: Double
    var flashDirection: FlashDirection?

    var id: String { symbol }

    enum FlashDirection: Hashable {
        case up
        case down
    }

    enum PriceDirection {
        case up
        case down
        case unchanged
    }

    static let trackedSymbols: [String] = [
        "AAPL", "GOOG", "TSLA", "AMZN", "MSFT", "NVDA", "META", "AMD", "NFLX", "AVGO",
        "ADBE", "PYPL", "CRM", "ORCL", "CSCO", "IBM", "QCOM", "TXN", "AMAT", "MU",
        "LRCX", "NOW", "INTU", "ISRG", "SPOT"
    ]

    static func initialStocks() -> [Stock] {
        trackedSymbols.enumerated().map { index, symbol in
            let seedPrice = 90.0 + (Double(index) * 17.35)
            return Stock(symbol: symbol,
                         price: seedPrice,
                         changePercent: 0,
                         previousPrice: seedPrice,
                         flashDirection: nil
            )
        }
    }

    var direction: PriceDirection {
        if price > previousPrice { return .up }
        if price < previousPrice { return .down }
        return .unchanged
    }

    var directionIndicator: String {
        switch direction {
        case .up: return "↑"
        case .down: return "↓"
        case .unchanged: return ""
        }
    }

    var directionColor: Color {
        switch direction {
        case .up: return .green
        case .down: return .red
        case .unchanged: return .secondary
        }
    }

    var description: String {
        "\(symbol) is tracked in the real-time simulation feed."
    }

    var flashColor: Color {
        switch flashDirection {
        case .up:
            return Color.green.opacity(0.22)
        case .down:
            return Color.red.opacity(0.22)
        case .none:
            return .clear
        }
    }
}
