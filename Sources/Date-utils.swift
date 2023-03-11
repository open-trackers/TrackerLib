//
//  Date-utils.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

/// Split "23:59:30" to (23, 59, 30).
/// NOTE: tolerates hour greater than 23 and minute greater than 59.
public func splitTime(_ hhmmss: String) -> (Int, Int, Int)? {
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

/// Split into local date/time in format "YYYY-MM-DD" and "hh:mm:ss" (24hr).
/// NOTE: created for use with SectionedFetchRequest.
/// NOTE: may need more tests
public func splitDateLocal(_ srcDate: Date, tz: TimeZone = TimeZone.current) -> (date: String, time: String)? {
    let df = ISO8601DateFormatter()
    df.timeZone = tz

    let raw = df.string(from: srcDate) // 2022-02-04T18:20:05-07:00

    let pattern = #/^(\d{4}-\d{2}-\d{2})T(\d{2}:\d{2}:\d{2})/#

    guard let result = raw.firstMatch(of: pattern) else { return nil }
    return (String(result.1), String(result.2))
}

/// Merge YYYY-MM-DD and optionally 00:00:00 together into a Date()
/// Will assume that time is local to time zone.
/// If no date specified, will assume local midnight.
/// NOTE: may need more tests
public func mergeDateLocal(dateStr: String,
                           timeStr: String? = nil,
                           tz: TimeZone = TimeZone.current) -> Date?
{
    let df = ISO8601DateFormatter()
    let seconds = tz.secondsFromGMT()
    let hours: Int = seconds / 3600
    let minutes: Int = seconds / 60 % 60
    let offset = String(format: "%+03d%02d", hours, minutes)
    let midnight = "00:00:00"
    let combined = "\(dateStr)T\(timeStr ?? midnight)\(offset)"
    return df.date(from: combined)
}

public func getSubjectiveDate(startOfDay: Int, // secs since midnight
                              now: Date = Date.now,
                              tz: TimeZone = TimeZone.current) -> (date: String, time: String)?
{
    let dayStartHour = startOfDay / 3600
    let dayStartMinute = startOfDay % 60
    return getSubjectiveDate(dayStartHour: dayStartHour, dayStartMinute: dayStartMinute, now: now, tz: tz)
}

/// Get the 'subjective' date based on user-specified starting time of day, local time, and current time.
///
/// Note that the time component may be greater than "23:59:59" (e.g., "27:30:00" for 3:30:00a) if representing a
/// surplus of time from the day prior. This is not only for sorting purposes, but also to allow a subjective
/// date to be converted back to a normal one.
///
/// Example: with threshold (aka when the 'subjective' day starts) at 5:30:00a:
/// * if current local time is 4:00:00a, return yesterday's date and a time of "28:00:00" (24 + 4).
/// * If current local time is 6:00:00a, return today's date and a time of "06:00:00".
///
/// Returns date result as "YYYY-MM-DD" and time as "hh:mm:ss".
public func getSubjectiveDate(dayStartHour: Int,
                              dayStartMinute: Int,
                              now: Date = Date.now,
                              tz: TimeZone = TimeZone.current) -> (date: String, time: String)?
{
    guard (0 ... 23).contains(dayStartHour),
          (0 ... 59).contains(dayStartMinute)
    else { return nil }

    let secondsInHour = 3600
    let secondsInMinute = 60
    let hoursInDay = 24
    let secondsInDay = hoursInDay * secondsInHour

    let thresholdSecs = TimeInterval(dayStartHour * secondsInHour + dayStartMinute * secondsInMinute) // eg, 5:30a is 19,800

    var cal = Calendar.current
    cal.timeZone = tz
    let startOfDay = cal.startOfDay(for: now)
    let nowSecs = now.timeIntervalSince(startOfDay) // 10:47:00a is 38,862

    // if earlier than the threshold, roll back 24 hours
    let rollback = nowSecs < thresholdSecs
    let netNow: Date = {
        if rollback {
            return now.addingTimeInterval(-1 * TimeInterval(secondsInDay))
        }
        return now
    }()

    guard let (dateStr, timeStr) = splitDateLocal(netNow, tz: tz) else { return nil }

    if !rollback { return (dateStr, timeStr) } // normal situation

    // rollback situation: add 24 to the hour (e.g., "02:03:00" -> "26:03:00")

    guard let (hour, minute, second) = splitTime(timeStr) else { return nil }

    let netHour = hoursInDay + hour

    let extraTimeStr = String(format: "%02d:%02d:%02d", netHour, minute, second)

    return (dateStr, extraTimeStr)
}
