//
//  SinceTests.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

@testable import TrackerLib
import XCTest

final class SinceTests: TestBase {
    let routineArchiveID = UUID()
    let taskArchiveID1 = UUID()
    let taskArchiveID2 = UUID()

    let earlierAtStr = "2023-01-13T09:55:00Z"
    var earlierAt: Date!
    let startingAtStr = "2023-01-13T10:00:00Z"
    var startingAt: Date!
    let runningAt1Str = "2023-01-13T12:00:00Z"
    var runningAt1: Date!

    override func setUpWithError() throws {
        earlierAt = df.date(from: earlierAtStr)
        startingAt = df.date(from: startingAtStr)
        runningAt1 = df.date(from: runningAt1Str)

        try super.setUpWithError()
    }

    func testNoStartedAt() throws {
        XCTAssertNil(getSinceInterval())
        XCTAssertNil(getSinceInterval(duration: 0))
        XCTAssertNil(getSinceInterval(duration: 0, now: Date.now))
        XCTAssertNil(getSinceInterval(now: Date.now))
    }

    func testStartedAt() throws {
        let t = getSinceInterval(startedAt: startingAt, now: runningAt1)
        XCTAssertEqual(7200, t)
    }

    func testLaggingTimer() throws {
        let t = getSinceInterval(startedAt: startingAt, now: earlierAt)
        XCTAssertEqual(0, t)
    }

    func testStartedAtWithNoReduceBy() throws {
        let t = getSinceInterval(startedAt: startingAt, duration: 0, now: runningAt1)
        XCTAssertEqual(7200, t)
    }

    func testStartedAtWithNegativeReduceBy() throws {
        let t = getSinceInterval(startedAt: startingAt, duration: -1000, now: runningAt1)
        XCTAssertEqual(7200, t)
    }

    func testStartedAtWithLowPositiveReduceBy() throws {
        let t = getSinceInterval(startedAt: startingAt, duration: 1000, now: runningAt1)
        XCTAssertEqual(6200, t)
    }

    func testStartedAtWithHighPositiveReduceBy() throws {
        let t = getSinceInterval(startedAt: startingAt, duration: 10000, now: runningAt1)
        XCTAssertEqual(0, t)
    }
}
