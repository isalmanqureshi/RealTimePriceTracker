# RealTimePriceTracker

SwiftUI iOS app that simulates real-time stock prices for 25 symbols over a shared WebSocket echo connection.

## Highlights

- Exactly 25 required symbols.
- Single shared WebSocket connection for app lifecycle.
- JSON payload shape:
  - `{"symbol":"AAPL","price":226.84,"changePercent":1.23}`
- Feed updates every 2 seconds when started.
- Updates apply only from echoed WebSocket messages.
- List sorted by price descending.
- Deep links: `stocks://symbol/NVDA`.

## Architecture (MVVM + Protocol-driven Services)

### Models
- `Stock` (`Identifiable`)
- `StockMessage` (`Codable`)

### Protocols
- `WebSocketServicing`
- `PriceFeedGenerating`

### Services 
- `WebSocketClient` (low-level socket)
- `WebSocketManager` (protocol-conforming service)
- `PriceFeedEngine` (volatility simulation ±0.2%...±2.5%)

### ViewModel
- `StocksViewModel` owns stocks, feed state, connection state, sorting, flashing, and message application.
- Depends only on protocols via constructor injection.

### Views
- 100% SwiftUI.
- Views consume `@EnvironmentObject var viewModel: StocksViewModel`.
- Navigation via `NavigationStack` + `.navigationDestination(for: Stock.self)`.

## Testing
