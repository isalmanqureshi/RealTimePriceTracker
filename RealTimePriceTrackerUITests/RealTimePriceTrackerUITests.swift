//
//  RealTimePriceTrackerUITests.swift
//  RealTimePriceTrackerUITests
//
//  Created by Salman Qureshi on 3/4/26.
//

import XCTest

final class RealTimePriceTrackerUITests: XCTestCase {
    
    @MainActor
    func testFeedToDetailsNavigation() throws {
        let app = XCUIApplication()
        app.launch()
        
        XCTAssertTrue(app.buttons["row_AAPL"].firstMatch.waitForExistence(timeout: 5))
        app.buttons["row_AAPL"].firstMatch.tap()
        
        XCTAssertTrue(app.navigationBars["AAPL"].firstMatch.waitForExistence(timeout: 5))
    }
}
