# RealTimePriceTracker

SwiftUI iOS app that simulates real-time stock prices for 25 symbols over a shared WebSocket echo connection.

## Screen Recording (Simulator)
![LiveTracker](https://github.com/user-attachments/assets/f9c5754b-1cbf-4573-994b-683de494d8ed)


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
- `TickerServicing`

### Services 
- `WebSocketClient` (low-level socket)
- `WebSocketManager` (protocol-conforming service)
- `PriceFeedEngine` (volatility simulation ±0.2%...±2.5%)
- `TimerTickerService` (runtime ticker)

### DI 
- `AppDependencies` with `.live()` composition.
- Live dependencies create exactly one websocket service instance used by `StocksViewModel`.

### ViewModel
- `StocksViewModel` owns stocks, feed state, connection state, sorting, flashing, and message application.
- Depends only on protocols via constructor injection.

### Views
- 100% SwiftUI.
- Views consume `@EnvironmentObject var viewModel: StocksViewModel`.
- Navigation via `NavigationStack` + `.navigationDestination(for: Stock.self)`.

## Deep Link

Configured URL scheme: `stocks`

Examples:
- `stocks://symbol/AAPL`
- `stocks://symbol/NVDA`

## Testing
Unit tests use mocks/fakes to avoid network and real timers:
- manual ticker tick injection,
- inbound message injection,
- deterministic sorting/update assertions.

## Local Run

1. Open `RealTimePriceTracker.xcodeproj` in Xcode.
2. Select an iOS simulator (for example iPhone 16).
3. Build and run.
4. Tap **Start** to begin updates and **Stop** to pause feed updates.
