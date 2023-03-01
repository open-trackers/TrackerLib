//
//  BaseCoreDataStack-stores.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData
import os

import Collections

extension BaseCoreDataStack {
    // MARK: - Public Methods

    public func getStore(_ context: NSManagedObjectContext, storeKey: String = BaseCoreDataStack.defaultStoreKey) -> NSPersistentStore? {
        guard let url = stores[storeKey]?.url,
              let psc = context.persistentStoreCoordinator,
              let store = psc.persistentStore(for: url)
        else {
            return nil
        }
        return store
    }

    // MARK: - Internal Methods

    internal func getStoreDescription(storeKey: String) -> NSPersistentStoreDescription {
        let url: URL = {
            let defaultDirectoryURL = NSPersistentContainer.defaultDirectoryURL()
            let suffix = storeKey.capitalized
            let baseFileName = "\(fileNamePrefix)\(baseFileName)\(suffix)"

            return defaultDirectoryURL.appendingPathComponent(baseFileName).appendingPathExtension("sqlite")
        }()

        let desc = NSPersistentStoreDescription(url: url)

        // enable history tracking (for notifications)
        desc.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        desc.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        // these are already set as "YES" by default
//        desc.setOption(true as NSNumber, forKey: NSMigratePersistentStoresAutomaticallyOption)
//        desc.setOption(true as NSNumber, forKey: NSInferMappingModelAutomaticallyOption)

        if let cloudPrefix {
            let cloudSuffix: String = {
                guard storeKey.count > 0 else { return "" }
                return ".\(storeKey.lowercased())"
            }()
            let identifier = "\(cloudPrefix)\(cloudSuffix)"
            desc.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: identifier)
        }

        return desc
    }
}
