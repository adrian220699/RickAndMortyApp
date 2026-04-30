//
//  RickAndMortyAppUITests.swift
//  RickAndMortyAppUITests
//
//  Created by Adrian Flores Herrera on 4/29/26.
//

import XCTest

final class RickAndMortyAppUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func test_fullCharacterFlow() {

        let firstCell = app.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5))

        firstCell.tap()

        let favoriteButton = app.buttons["favoriteButton"]
        XCTAssertTrue(favoriteButton.waitForExistence(timeout: 5))

        favoriteButton.tap()

        app.navigationBars.buttons.element(boundBy: 0).tap()

        XCTAssertTrue(app.cells.firstMatch.exists)
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
