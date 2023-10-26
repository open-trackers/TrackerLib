//
//  BaseCoreDataStack-container.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData
import os

extension BaseCoreDataStack {
    func getContainer() -> NSPersistentContainer {
        let isCloud = cloudPrefix != nil
        let model = loadModel(modelName: modelName)
        let container = isCloud
            ? NSPersistentCloudKitContainer(name: modelName, managedObjectModel: model)
            : NSPersistentContainer(name: modelName, managedObjectModel: model)

        container.persistentStoreDescriptions = stores.values.elements

        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                self.logger.error("\(#function): loading persistent stores, \(error) \(error.userInfo)")
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })

        // provide transaction author to distinguish between local and remote changes
        container.viewContext.transactionAuthor = appTransactionAuthorName

        // ensure viewContext receives changes from saves of backgroundContext
        container.viewContext.automaticallyMergesChangesFromParent = true

        // in-memory changes will win any conflict
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        // use generational querying, where this context will pin itself to the generation of the database when it first loads data
        // NOTE not used until more research is done on whether it's needed
//        do {
//            try container.viewContext.setQueryGenerationFrom(.current)
//        } catch {
//            logger.error("\(#function) setQueryGenerationFrom ERROR \(error)")
//        }

        // NOTE: the following is necessary to fully initialize the development container(s)
        //       so that a complete deployment to production is possible in CloudKit dashboard.
        // NOTE: Both containers need to be deployed to production.
        #if DEBUG
            if isCloud,
               let cloudContainer = container as? NSPersistentCloudKitContainer
            {
                do {
                    logger.notice("\(#function) initializeCloudKitSchema")
                    try cloudContainer.initializeCloudKitSchema(options: [])
                } catch {
                    logger.error("\(#function) initializeCloudKitSchema ERROR \(error)")
                }
            }
        #endif

        return container
    }
}
