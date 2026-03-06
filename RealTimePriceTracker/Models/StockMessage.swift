//
//  StockMessage.swift
//  RealTimePriceTracker
//
//  Created by Salman Qureshi on 3/6/26.
//
import Foundation

struct StockMessage: Codable {
    let symbol: String
    let price: Double
    let changePercent: Double
}
