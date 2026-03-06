//
//  RealTimePriceTrackerApp.swift
//  RealTimePriceTracker
//
//  Created by Salman Qureshi on 3/4/26.
//

import SwiftUI

@main
struct RealTimePriceTrackerApp: App {
    @StateObject private var viewModel: StocksViewModel
    @State private var path: [Stock] = []
    
    init() {
        _viewModel = StateObject(wrappedValue: StocksViewModel(dependencies: .live()))
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $path) {
                FeedView()
                    .navigationDestination(for: Stock.self) { stock in
                        SymbolDetailsView(stock: stock)
                    }
            }
            .environmentObject(viewModel)
            .onOpenURL { handleDeepLink($0) }
        }
    }
    
    /// Deep link: stocks://symbol/{symbol} that opens the details screen.
    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "stocks", url.host == "symbol" else { return }
        let symbol = url.pathComponents.dropFirst().first?.uppercased() ?? ""
        guard let stock = viewModel.stock(for: symbol) else { return }
        path = [stock]
    }
}
