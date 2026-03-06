//
//  TimeTickerService.swift
//  RealTimePriceTracker
//
//  Created by Salman Qureshi on 3/6/26.
//

import Foundation
import Combine

protocol TickerServicing {
    var tickPublisher: AnyPublisher<Date, Never> { get }
    func start(interval: TimeInterval)
    func stop()
}

final class TimerTickerService: TickerServicing {
    private let tick = PassthroughSubject<Date, Never>()
    private var timerCancellable: AnyCancellable?

    var tickPublisher: AnyPublisher<Date, Never> {
        tick.eraseToAnyPublisher()
    }

    func start(interval: TimeInterval) {
        guard timerCancellable == nil else { return }

        timerCancellable = Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] date in
                self?.tick.send(date)
            }
    }

    func stop() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }
}
