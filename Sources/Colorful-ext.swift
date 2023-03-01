//
//  Colorful-ext.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData
import SwiftUI

// protocol Colorful {
//    var color: Data? { get set }
//    func getColor() -> Color?
//    func setColor(_ : Color?)
// }

public extension NSManagedObject {
    private var key: String { "color" }

    func getColor() -> Color? {
        let decoder = JSONDecoder()
        if let data = value(forKey: key) as? Data,
           let decoded = try? decoder.decode(Color.self, from: data)
        {
            return decoded
        }
        return nil
    }

    // Save specified color, properly encoded, to color, or save as nil if none.
    // NOTE: does NOT save context
    func setColor(_ nuColor: Color?) {
        if nuColor == nil {
            setValue(nil, forKey: key)
            return
        }
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(nuColor) {
            setValue(encoded, forKey: key)
        }
    }
}
