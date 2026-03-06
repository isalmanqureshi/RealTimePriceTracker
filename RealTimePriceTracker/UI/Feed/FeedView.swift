//
//  FeedView.swift
//  RealTimePriceTracker
//
//  Created by Salman Qureshi on 3/5/26.
//

import SwiftUI

struct FeedView: View {
    @EnvironmentObject var viewModel: StocksViewModel
    
    var body: some View {
        List(viewModel.stocks) { stock in
            NavigationLink(value: stock) {
                StockRowView(stock: stock)
            }
            .accessibilityIdentifier("row_\(stock.symbol)")
        }
        .navigationTitle("StockTracker")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Label(viewModel.isConnected ? "Connected" : "Disconnected", systemImage: viewModel.isConnected ? "dot.radiowaves.left.and.right" : "wifi.slash")
                    .foregroundStyle(viewModel.isConnected ? .green : .red)
                    .font(.caption)
                    .accessibilityIdentifier("connectionIndicator")
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button(viewModel.isFeedRunning ? "Stop" : "Start") {
                    viewModel.toggleFeed()
                }
                .accessibilityIdentifier("toggleFeedButton")
            }
        }
    }
}
