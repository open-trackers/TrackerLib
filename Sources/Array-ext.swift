//
//  Array-ext.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

extension Array: @retroactive RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else {
            return nil
        }
        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}

/// used to maintain MRU (Most Recently Used) values
public extension Array where Element: Equatable {
    mutating func updateMRU(with value: Element, maxCount: Int = 10) {
        if let foundIndex = firstIndex(of: value) {
            if foundIndex > 0 {
                remove(at: foundIndex)
                insert(value, at: 0)
            }
        } else {
            if count == maxCount {
                removeLast()
            }
            insert(value, at: 0)
        }
    }
}
