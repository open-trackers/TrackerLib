//
//  SplitDateTests.swift
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

final class SplitDateTests: TestBase {
    let timestampStr = "2022-02-05T01:20:05Z"
    var timestamp: Date!

    override func setUpWithError() throws {
        try super.setUpWithError()

        timestamp = df.date(from: timestampStr)
    }

    func testSimple() throws {
        let (dateStr, timeStr) = splitDate(timestamp,
                                           tz: .init(abbreviation: "MST")!)!
        // from 2022-02-04T18:20:05-07:00
        XCTAssertEqual("2022-02-04", dateStr)
        XCTAssertEqual("18:20:05", timeStr)
    }
}
