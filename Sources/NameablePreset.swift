//
//  NameablePreset.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

public protocol NameablePreset: Hashable {
    var title: String { get set }
}

extension String: NameablePreset {
    public var title: String {
        get {
            self
        }
        set {
            self = newValue
        }
    }
}
