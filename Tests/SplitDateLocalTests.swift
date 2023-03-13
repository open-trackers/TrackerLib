//
//  SplitDateLocalTests.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

@testable import TrackerLib
import XCTest

final class SplitDateLocalTests: TestBase {
    let timestampStr = "2022-02-05T01:20:05Z"
    var timestamp: Date!

    override func setUpWithError() throws {
        try super.setUpWithError()

        timestamp = df.date(from: timestampStr)
    }

    func testSimpleSplit() throws {
        let (dateStr, timeStr) = timestamp.splitToLocal(tz: .init(abbreviation: "MST")!)!
        // from 2022-02-04T18:20:05-07:00
        XCTAssertEqual("2022-02-04", dateStr)
        XCTAssertEqual("18:20:05", timeStr)
    }

    func testSimpleMerge() throws {
        let dateStr = "2022-02-04"
        let timeStr = "18:20:05"

        let merged = Date.mergeFromLocal(dateStr: dateStr, timeStr: timeStr,
                                         tz: .init(abbreviation: "MST")!)

        XCTAssertEqual(timestamp, merged)
    }

    func testSimpleMergeMidnight() throws {
        let dateStr = "2022-02-05"
        let timeStr = "00:00:00"

        let merged = Date.mergeFromLocal(dateStr: dateStr, timeStr: timeStr,
                                         tz: .init(abbreviation: "MST")!)

        let ts2Str = "2022-02-05T07:00:00+0000"
        let ts2 = df.date(from: ts2Str)

        XCTAssertEqual(ts2, merged)
    }
}
