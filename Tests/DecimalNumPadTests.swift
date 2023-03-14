//
//  DecimalNumPadTests.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//

import XCTest

@testable import TrackerLib

class DecimalNumPadTests: XCTestCase {
    func testNoArgs() throws {
        let x = DecimalNumPad()
        XCTAssertEqual("0", x.sValue)
        XCTAssertEqual(0, x.decimalValue)
    }

    func testInitZero() throws {
        let x = DecimalNumPad(0)
        XCTAssertEqual("0", x.sValue)
        XCTAssertEqual(0, x.decimalValue)
    }

    func testInit1() throws {
        let x = DecimalNumPad(1)
        XCTAssertEqual("1", x.sValue)
        XCTAssertEqual(1, x.decimalValue)
    }

    func testInit1_0() throws {
        let x = DecimalNumPad(1.0)
        XCTAssertEqual("1", x.sValue)
        XCTAssertEqual(1, x.decimalValue)
    }

    func testInit1_1() throws {
        let x = DecimalNumPad(1.1)
        XCTAssertEqual("1.1", x.sValue)
        XCTAssertEqual(1.1, x.decimalValue)
    }

    func testInitBad() throws {
        let x = DecimalNumPad(-1, range: 0 ... 1)
        XCTAssertEqual("0", x.sValue)
        XCTAssertEqual(0, x.decimalValue)
    }

    func testValueLargeWithinPrecision() throws {
        let x = DecimalNumPad(2_348_938.93, precision: 2)
        XCTAssertEqual("2348938.93", x.sValue)
        XCTAssertEqual(2_348_938.93, x.decimalValue)
    }

    func testValueLargeBeyondPrecisionRounds() throws {
        let x = DecimalNumPad(2_348_938.936, precision: 2)
        XCTAssertEqual("2348938.94", x.sValue)
        XCTAssertEqual(2_348_938.94, x.decimalValue)
    }

    func testBadDigits() throws {
        var x = DecimalNumPad(34.3)
        x.digitAction(-1)
        XCTAssertEqual("34.3", x.sValue)
        XCTAssertEqual(34.3, x.decimalValue)

        x.digitAction(10)
        XCTAssertEqual("34.3", x.sValue)
        XCTAssertEqual(34.3, x.decimalValue)
    }

    func testAddAndRemoveDigits() throws {
        var x = DecimalNumPad()
        x.digitAction(1)
        XCTAssertEqual("1", x.sValue)
        XCTAssertEqual(1, x.decimalValue)

        x.digitAction(2)
        XCTAssertEqual("12", x.sValue)
        XCTAssertEqual(12, x.decimalValue)

        x.backspaceAction()
        XCTAssertEqual("1", x.sValue)
        XCTAssertEqual(1, x.decimalValue)

        x.backspaceAction()
        XCTAssertEqual("0", x.sValue)
        XCTAssertEqual(0, x.decimalValue)
    }

    func testRedundantZero() throws {
        var x = DecimalNumPad()
        XCTAssertEqual("0", x.sValue)
        XCTAssertEqual(0, x.decimalValue)

        x.digitAction(0)
        XCTAssertEqual("0", x.sValue)
        XCTAssertEqual(0, x.decimalValue)
    }

    func testAddDigitAndDecimalPoint() throws {
        var x = DecimalNumPad()
        x.digitAction(1)
        XCTAssertEqual("1", x.sValue)
        XCTAssertEqual(1, x.decimalValue)

        x.decimalPointAction()
        XCTAssertEqual("1.", x.sValue)
        XCTAssertEqual(1, x.decimalValue)

        x.digitAction(2)
        XCTAssertEqual("1.2", x.sValue)
        XCTAssertEqual(1.2, x.decimalValue)
    }

    func testBackspaceDecimalPoint() throws {
        var x = DecimalNumPad(1.2)
        XCTAssertEqual("1.2", x.sValue)
        XCTAssertEqual(1.2, x.decimalValue)

        x.backspaceAction()
        XCTAssertEqual("1.", x.sValue)
        XCTAssertEqual(1, x.decimalValue)

        x.backspaceAction()
        XCTAssertEqual("1", x.sValue)
        XCTAssertEqual(1, x.decimalValue)

        x.backspaceAction()
        XCTAssertEqual("0", x.sValue)
        XCTAssertEqual(0, x.decimalValue)
    }

    func testRedundantBackspace() throws {
        var x = DecimalNumPad(1)
        XCTAssertEqual("1", x.sValue)
        XCTAssertEqual(1, x.decimalValue)

        x.backspaceAction()
        XCTAssertEqual("0", x.sValue)
        XCTAssertEqual(0, x.decimalValue)

        x.backspaceAction()
        XCTAssertEqual("0", x.sValue)
        XCTAssertEqual(0, x.decimalValue)
    }

    func testRedundantAdjacentDecimalPoint() throws {
        var x = DecimalNumPad()
        x.digitAction(1)
        XCTAssertEqual("1", x.sValue)
        XCTAssertEqual(1, x.decimalValue)

        x.decimalPointAction()
        XCTAssertEqual("1.", x.sValue)
        XCTAssertEqual(1, x.decimalValue)

        x.decimalPointAction()
        XCTAssertEqual("1.", x.sValue)
        XCTAssertEqual(1, x.decimalValue)
    }

    func testRedundantSecondDecimalPoint() throws {
        var x = DecimalNumPad(1.2)

        XCTAssertEqual("1.2", x.sValue)
        XCTAssertEqual(1.2, x.decimalValue)

        x.decimalPointAction()
        XCTAssertEqual("1.2", x.sValue)
        XCTAssertEqual(1.2, x.decimalValue)
    }

    func testDecimalPointBackspace() throws {
        var x = DecimalNumPad()
        x.digitAction(1)
        XCTAssertEqual("1", x.sValue)
        XCTAssertEqual(1, x.decimalValue)

        x.decimalPointAction()
        XCTAssertEqual("1.", x.sValue)
        XCTAssertEqual(1, x.decimalValue)

        x.decimalPointAction()
        XCTAssertEqual("1.", x.sValue)
        XCTAssertEqual(1, x.decimalValue)
    }

    func testPenny() throws {
        var x = DecimalNumPad(precision: 2)
        XCTAssertEqual("0", x.sValue)
        XCTAssertEqual(0, x.decimalValue)
        XCTAssertEqual(0, x.currentPrecision)

        x.decimalPointAction()
        XCTAssertEqual("0.", x.sValue)
        XCTAssertEqual(0, x.decimalValue)
        XCTAssertEqual(0, x.currentPrecision)

        x.digitAction(0)
        XCTAssertEqual("0.0", x.sValue)
        XCTAssertEqual(0, x.decimalValue)
        XCTAssertEqual(1, x.currentPrecision)

        x.digitAction(1)
        XCTAssertEqual("0.01", x.sValue)
        XCTAssertEqual(0.01, x.decimalValue)
        XCTAssertEqual(2, x.currentPrecision)
    }

    func testIgnoreIfBeyondPrecision() throws {
        var x = DecimalNumPad(0.01, precision: 2)

        XCTAssertEqual("0.01", x.sValue)
        XCTAssertEqual(0.01, x.decimalValue)
        XCTAssertEqual(2, x.currentPrecision)

        x.digitAction(9)
        XCTAssertEqual("0.01", x.sValue)
        XCTAssertEqual(0.01, x.decimalValue)
        XCTAssertEqual(2, x.currentPrecision)
    }

    func testInitializeOutsidePrecision() throws {
        let x = DecimalNumPad(10.18, precision: 1)
        XCTAssertEqual("10.2", x.sValue)
        XCTAssertEqual(10.2, x.decimalValue)
    }

    func testInitializeInsideRange() throws {
        let x = DecimalNumPad(10, range: 0 ... 10)
        XCTAssertEqual("10", x.sValue)
        XCTAssertEqual(10, x.decimalValue)
    }

    func testInitializeOutsideRange() throws {
        let x = DecimalNumPad(10.01, precision: 2, range: 0 ... 10)
        XCTAssertEqual("10", x.sValue)
        XCTAssertEqual(10, x.decimalValue)
    }

    func testIgnoreIfOutsideRange() throws {
        var x = DecimalNumPad(10, precision: 2, range: 0 ... 10)
        XCTAssertEqual("10", x.sValue)
        XCTAssertEqual(10, x.decimalValue)

        x.decimalPointAction()
        XCTAssertEqual("10.", x.sValue)
        XCTAssertEqual(10, x.decimalValue)
        XCTAssertEqual(0, x.currentPrecision)

        x.digitAction(0)
        XCTAssertEqual("10.0", x.sValue)
        XCTAssertEqual(10, x.decimalValue)
        XCTAssertEqual(1, x.currentPrecision)

        x.digitAction(1)
        XCTAssertEqual("10.0", x.sValue)
        XCTAssertEqual(10.0, x.decimalValue)
        XCTAssertEqual(1, x.currentPrecision)

        x.digitAction(0)
        XCTAssertEqual("10.00", x.sValue)
        XCTAssertEqual(10, x.decimalValue)
        XCTAssertEqual(2, x.currentPrecision)
    }
}
