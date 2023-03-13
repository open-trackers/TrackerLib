//
//  SubjectiveDateTests.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import XCTest

@testable import TrackerLib

class SubjectiveDateTests: TestBase {
    let tzStr = "-07:00"
    let tz = TimeZone(secondsFromGMT: -7 * 3600)!

    let yesterday = "2023-01-12"
    let today = "2023-01-13"

    let beforeMidnight = "2023-01-12T23:59:59"
    var beforeMidnightDate: Date!
    let midnightStr = "2023-01-13T00:00:00"
    var midnightDate: Date!
    let noonStr = "2023-01-13T12:00:00"
    var noonDate: Date!

    // using 05:30 as a threshold
    let startHour = 5
    let startMinute = 30
    let preThresholdStr = "2023-01-13T05:29:59"
    var preThresholdDate: Date!
    let thresholdStr = "2023-01-13T05:30:00"
    var thresholdDate: Date!
    let postThresholdStr = "2023-01-13T05:31:00"
    var postThresholdDate: Date!

    override func setUpWithError() throws {
        try super.setUpWithError()

        beforeMidnightDate = df.date(from: "\(beforeMidnight)\(tzStr)")
        midnightDate = df.date(from: "\(midnightStr)\(tzStr)")
        noonDate = df.date(from: "\(noonStr)\(tzStr)")
        preThresholdDate = df.date(from: "\(preThresholdStr)\(tzStr)")
        thresholdDate = df.date(from: "\(thresholdStr)\(tzStr)")
        postThresholdDate = df.date(from: "\(postThresholdStr)\(tzStr)")
    }

    func testDayStartParams() throws {
        XCTAssertNotNil(noonDate.getSubjectiveDate(dayStartHour: 0, dayStartMinute: 0))
        XCTAssertNotNil(noonDate.getSubjectiveDate(dayStartHour: 23, dayStartMinute: 0))
        XCTAssertNotNil(noonDate.getSubjectiveDate(dayStartHour: 0, dayStartMinute: 59))
        XCTAssertNil(noonDate.getSubjectiveDate(dayStartHour: -1, dayStartMinute: 0))
        XCTAssertNil(noonDate.getSubjectiveDate(dayStartHour: 0, dayStartMinute: -1))
        XCTAssertNil(noonDate.getSubjectiveDate(dayStartHour: 24, dayStartMinute: 0))
        XCTAssertNil(noonDate.getSubjectiveDate(dayStartHour: 0, dayStartMinute: 60))
    }

    func testYesterdayBeforeMidnight() throws {
        let pair = beforeMidnightDate.getSubjectiveDate(dayStartHour: startHour, dayStartMinute: startMinute, tz: tz)
        XCTAssertEqual(yesterday, pair?.0)
        XCTAssertEqual("23:59:59", pair?.1)
    }

    func testYesterdayAtMidnight() throws {
        let pair = midnightDate.getSubjectiveDate(dayStartHour: startHour, dayStartMinute: startMinute, tz: tz)
        XCTAssertEqual(yesterday, pair?.0)
        XCTAssertEqual("24:00:00", pair?.1)
    }

    func testYesterdayPreThreshold() throws {
        let pair = preThresholdDate.getSubjectiveDate(dayStartHour: startHour, dayStartMinute: startMinute, tz: tz)
        XCTAssertEqual(yesterday, pair?.0)
        XCTAssertEqual("29:29:59", pair?.1)
    }

    func testTodayAtThreshold() throws {
        let pair = thresholdDate.getSubjectiveDate(dayStartHour: startHour, dayStartMinute: startMinute, tz: tz)
        XCTAssertEqual(today, pair?.0)
        XCTAssertEqual("05:30:00", pair?.1)
    }

    func testTodayAfterThreshold() throws {
        let pair = postThresholdDate.getSubjectiveDate(dayStartHour: startHour, dayStartMinute: startMinute, tz: tz)
        XCTAssertEqual(today, pair?.0)
        XCTAssertEqual("05:31:00", pair?.1)
    }
}
