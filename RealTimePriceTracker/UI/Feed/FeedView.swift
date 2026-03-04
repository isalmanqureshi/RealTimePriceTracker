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
        }
        .navigationTitle("StockTracker")
    }
}
