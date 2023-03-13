//
//  Date-ext-split-merge.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

public extension Date {
    private static let dateFormat = "yyyy-MM-dd HH:mm:ss"

    /// Split a Date into a local "yyyy-MM-dd" and "HH:mm:ss" (24hr) for the specified time zone.
    func splitToLocal(tz: TimeZone = TimeZone.current) -> (date: String, time: String)? {
        let df = DateFormatter()
        df.dateFormat = Self.dateFormat
        df.timeZone = tz
        let localStr = df.string(from: self) // 2022-02-04 18:20:05
        let result = localStr.split(separator: " ")
        guard result.count == 2 else { return nil }
        return (String(result[0]), String(result[1]))
    }

    /// Merge the local "yyyy-MM-dd" and "HH:mm:ss" (24hr) together into a Date().
    /// Will assume that day and time is local to the time zone.
    /// If no timezone specified, will assume system's current tz.
    static func mergeFromLocal(dateStr: String,
                               timeStr: String,
                               tz: TimeZone = TimeZone.current) -> Date?
    {
        let localStr = "\(dateStr) \(timeStr)"
        let df = DateFormatter()
        df.dateFormat = dateFormat
        df.timeZone = tz
        return df.date(from: localStr)
    }

    /// Split "23:59:30" to (23, 59, 30).
    /// NOTE: tolerates hour greater than 23 and minute greater than 59.
    internal static func splitTime(_ hhmmss: String) -> (Int, Int, Int)? {
        let pattern = #/^(\d{2}):(\d{2}):(\d{2})/#

        guard let result = hhmmss.firstMatch(of: pattern),
              case let rawHour = String(result.1),
              case let rawMin = String(result.2),
              case let rawSec = String(result.3),
              rawHour.count == 2,
              rawMin.count == 2,
              rawSec.count == 2,
              let hour = Int(rawHour),
              let minute = Int(rawMin),
              let second = Int(rawSec)
        else { return nil }

        return (hour, minute, second)
    }
}
