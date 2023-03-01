//
//  ArrayMRUTests.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import XCTest

@testable import TrackerLib

class ArrayMRUTests: XCTestCase {
    func testSimple() {
        let maxCount = 3
        var array = [Int]()

        array.updateMRU(with: 7, maxCount: maxCount)

        XCTAssertEqual([7], array)

        array.updateMRU(with: 4, maxCount: maxCount)

        XCTAssertEqual([4, 7], array)

        array.updateMRU(with: 18, maxCount: maxCount)

        XCTAssertEqual([18, 4, 7], array)

        array.updateMRU(with: 5, maxCount: maxCount)

        XCTAssertEqual([5, 18, 4], array)

        array.updateMRU(with: 4, maxCount: maxCount)

        XCTAssertEqual([4, 5, 18], array)

        array.updateMRU(with: 5, maxCount: maxCount)

        XCTAssertEqual([5, 4, 18], array)
    }
}
