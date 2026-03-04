//
//  SymbolDetailsView.swift
//  RealTimePriceTracker
//
//  Created by Salman Qureshi on 3/5/26.
//

import SwiftUI

struct SymbolDetailsView: View {
    
    @EnvironmentObject private var viewModel: StocksViewModel
    let stock: Stock
    
    var body: some View {
        let liveStock = viewModel.stock(for: stock.symbol) ?? stock
        
        VStack(alignment: .leading, spacing: 20) {

            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text(liveStock.price, format: .number.precision(.fractionLength(2)))
                    .font(.system(size: 44, weight: .bold, design: .rounded))

                Text(liveStock.directionIndicator)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(liveStock.directionColor)
            }

            Text(liveStock.description)
                .font(.body)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding()
        .navigationTitle(liveStock.symbol)
        .background(liveStock.flashColor)
    }
}
