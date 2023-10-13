//
//  TrackerError.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

/// Data layer errors
public enum TrackerError: Error, Equatable {
    case fetchError(msg: String)
    case missingData(msg: String)
    case invalidData(msg: String)
    case invalidStoreConfiguration(msg: String)
    case encodingError(msg: String)
    case archiveCreationFailure
    case invalidAction(msg: String)

    var localizedDescription: String {
        description
    }

    var description: String {
        switch self {
        case let .fetchError(msg): "Data fetch error: \(msg)"
        case let .missingData(msg): "Missing data: \(msg)"
        case let .invalidData(msg): "Invalid data: \(msg)"
        case let .invalidStoreConfiguration(msg): "Invalid store configuration: \(msg)"
        case let .encodingError(msg): "Encoding error: \(msg)"
        case .archiveCreationFailure: "Archive creation failure."
        case let .invalidAction(msg): "Invalid action: \(msg)"
        }
    }
}
