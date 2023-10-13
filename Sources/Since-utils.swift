//
//  Since-utils.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

// time interval since the last workout ended

// secondsSinceThingEnded = (now - (startedAt + duration))
public func getSinceInterval(startedAt: Date? = nil,
                             duration: TimeInterval? = nil,
                             now: Date = Date.now) -> TimeInterval?
{
    guard let startedAt else { return nil }

    // NOTE: now (driven by timer) may be lagging startedAt,
    // so clamping at 0.
    let baseSince = max(0, now.timeIntervalSince(startedAt))

    guard let duration,
          duration > 0
    else { return baseSince }

    return max(0, baseSince - duration)
}
