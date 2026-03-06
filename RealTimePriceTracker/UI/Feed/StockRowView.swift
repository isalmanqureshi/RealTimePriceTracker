//
//  StokcRowView.swift
//  RealTimePriceTracker
//
//  Created by Salman Qureshi on 3/5/26.
//

import SwiftUI

struct StockRowView: View {
    let stock: Stock
    
    var body: some View {
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
