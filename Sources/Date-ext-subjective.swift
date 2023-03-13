//
//  Date-ext-subjective.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

public extension Date {
    func getSubjectiveDate(startOfDay: Int, // secs since midnight
                           tz: TimeZone = TimeZone.current) -> (date: String, time: String)?
    {
        let dayStartHour = startOfDay / 3600
        let dayStartMinute = startOfDay % 60
        return getSubjectiveDate(dayStartHour: dayStartHour,
                                 dayStartMinute: dayStartMinute,
                                 tz: tz)
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
    func getSubjectiveDate(dayStartHour: Int,
                           dayStartMinute: Int,
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
        let startOfDay = cal.startOfDay(for: self)
        let nowSecs = timeIntervalSince(startOfDay) // 10:47:00a is 38,862

        // if earlier than the threshold, roll back 24 hours
        let rollback = nowSecs < thresholdSecs
        let netNow: Date = {
            if rollback {
                return self.addingTimeInterval(-1 * TimeInterval(secondsInDay))
            }
            return self
        }()

        guard let (dateStr, timeStr) = netNow.splitToLocal(tz: tz) else { return nil }

        if !rollback { return (dateStr, timeStr) } // normal situation

        // rollback situation: add 24 to the hour (e.g., "02:03:00" -> "26:03:00")

        guard let (hour, minute, second) = Date.splitTime(timeStr) else { return nil }

        let netHour = hoursInDay + hour

        let extraTimeStr = String(format: "%02d:%02d:%02d", netHour, minute, second)

        return (dateStr, extraTimeStr)
    }
}
