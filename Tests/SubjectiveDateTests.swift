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
        preThresholdDate = df.date(from: "\(preThresholdStr)\(tzStr)")
        thresholdDate = df.date(from: "\(thresholdStr)\(tzStr)")
        postThresholdDate = df.date(from: "\(postThresholdStr)\(tzStr)")
    }

    func testDayStartParams() throws {
        XCTAssertNotNil(getSubjectiveDate(dayStartHour: 0, dayStartMinute: 0))
        XCTAssertNotNil(getSubjectiveDate(dayStartHour: 23, dayStartMinute: 0))
        XCTAssertNotNil(getSubjectiveDate(dayStartHour: 0, dayStartMinute: 59))
        XCTAssertNil(getSubjectiveDate(dayStartHour: -1, dayStartMinute: 0))
        XCTAssertNil(getSubjectiveDate(dayStartHour: 0, dayStartMinute: -1))
        XCTAssertNil(getSubjectiveDate(dayStartHour: 24, dayStartMinute: 0))
        XCTAssertNil(getSubjectiveDate(dayStartHour: 0, dayStartMinute: 60))
    }

    func testYesterdayBeforeMidnight() throws {
        let pair = getSubjectiveDate(dayStartHour: startHour, dayStartMinute: startMinute, now: beforeMidnightDate, tz: tz)
        XCTAssertEqual(yesterday, pair?.0)
        XCTAssertEqual("23:59:59", pair?.1)
    }

    func testYesterdayAtMidnight() throws {
        let pair = getSubjectiveDate(dayStartHour: startHour, dayStartMinute: startMinute, now: midnightDate, tz: tz)
        XCTAssertEqual(yesterday, pair?.0)
        XCTAssertEqual("24:00:00", pair?.1)
    }

    func testYesterdayPreThreshold() throws {
        let pair = getSubjectiveDate(dayStartHour: startHour, dayStartMinute: startMinute, now: preThresholdDate, tz: tz)
        XCTAssertEqual(yesterday, pair?.0)
        XCTAssertEqual("29:29:59", pair?.1)
    }

    func testTodayAtThreshold() throws {
        let pair = getSubjectiveDate(dayStartHour: startHour, dayStartMinute: startMinute, now: thresholdDate, tz: tz)
        XCTAssertEqual(today, pair?.0)
        XCTAssertEqual("05:30:00", pair?.1)
    }

    func testTodayAfterThreshold() throws {
        let pair = getSubjectiveDate(dayStartHour: startHour, dayStartMinute: startMinute, now: postThresholdDate, tz: tz)
        XCTAssertEqual(today, pair?.0)
        XCTAssertEqual("05:31:00", pair?.1)
    }
}
