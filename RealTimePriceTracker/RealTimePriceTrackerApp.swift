//
//  RealTimePriceTrackerApp.swift
//  RealTimePriceTracker
//
//  Created by Salman Qureshi on 3/4/26.
//

import SwiftUI

@main
struct RealTimePriceTrackerApp: App {
    @StateObject private var viewModel = StocksViewModel()
    var body: some Scene {
        WindowGroup {
            NavigationStack() {
                FeedView()
                    .navigationDestination(for: Stock.self) { stock in
                        SymbolDetailsView(stock: stock)
                    }
            }
            .environmentObject(viewModel)
        }
    }
}
