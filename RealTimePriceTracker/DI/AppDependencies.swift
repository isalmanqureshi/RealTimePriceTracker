//
//  AppDependencies.swift
//  RealTimePriceTracker
//
//  Created by Salman Qureshi on 3/6/26.
//

import Foundation

struct AppDependencies {
    let webSocketService: WebSocketServicing
    let tickerService: TickerServicing
    let priceFeedService: PriceFeedGenerating

    static func live() -> AppDependencies {
        AppDependencies(
            webSocketService: WebSocketManager(client: WebSocketClient()),
            tickerService: TimerTickerService(),
            priceFeedService: PriceFeedEngine()
        )
    }
}
