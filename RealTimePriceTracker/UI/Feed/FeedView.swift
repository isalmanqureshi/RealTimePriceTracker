//
//  FeedView.swift
//  RealTimePriceTracker
//
//  Created by Salman Qureshi on 3/5/26.
//

import SwiftUI

struct FeedView: View {
    @StateObject var viewModel: StocksViewModel
    
    var body: some View {
        List(viewModel.stocks) { stock in
            NavigationLink(value: stock) {
                HStack {
                    Text(stock.symbol)
                        .font(.headline)
                    
                    Spacer()
                    
                    Text(stock.price, format: .number.precision(.fractionLength(2)))
                        .font(.system(.body, design: .monospaced))
                        .fontWeight(.semibold)
                    
                    Text(stock.directionIndicator)
                        .foregroundStyle(stock.directionColor)
                        .font(.headline.weight(.bold))
                        .frame(width: 20)
                }
                .padding(.vertical, 6)
                .listRowBackground(stock.flashColor)
            }
        }
        .navigationTitle("StockTracker")
    }
}
