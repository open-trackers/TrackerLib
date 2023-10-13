//
//  BaseCoreDataStack.swift
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

// TODO:
// var isICloudContainerAvailable: Bool {
//    FileManager.default.ubiquityIdentityToken != nil
//  }

// Multi-store support
// CloudKit support
// History change support (for de-duplication)
// support for segregated test/preview containers, using fileNamePrefix
open class BaseCoreDataStack {
    // MARK: - Parameters

    let modelName: String
    let baseFileName: String
    let cloudPrefix: String?
    let fileNamePrefix: String
    let appTransactionAuthorName: String
    let storeKeys: [String]

    public init(modelName: String,
                baseFileName: String,
                cloudPrefix: String? = nil,
                fileNamePrefix: String = "",
                appTransactionAuthorName: String = "app",
                storeKeys: [String] = [BaseCoreDataStack.defaultStoreKey])
    {
        self.modelName = modelName
        self.baseFileName = baseFileName
        self.cloudPrefix = cloudPrefix
        self.fileNamePrefix = fileNamePrefix
        self.appTransactionAuthorName = appTransactionAuthorName
        self.storeKeys = storeKeys
    }

    deinit {
        deinitStoreRemoteChangeNotification()
    }

    // MARK: - Properties

    public private(set) lazy var container: NSPersistentContainer = {
        precondition(Thread.isMainThread)

        let container = getContainer()

        // receive remote notifications of changes
        initStoreRemoteChangeNotification(container)

        return container
    }()

    // MARK: - Stores Support

    public static let defaultStoreKey = ""

    public typealias StoresDict = OrderedDictionary<String, NSPersistentStoreDescription>

    public lazy var stores: StoresDict = storeKeys.reduce(into: [:]) { dict, key in
        dict[key] = getStoreDescription(storeKey: key)
    }

    // MARK: - Model Support

    open func loadModel(modelName _: String) -> NSManagedObjectModel {
        fatalError("You must override loadModel()")
    }

    // MARK: - History / Remote Notification support

    lazy var tokenFileURL: URL = getTokenFileURL(name: baseFileName)

    // an operation queue for handling history processing tasks, including
    // * watching changes
    // * deduplicating
    // * triggering UI updates, if needed
    lazy var historyQueue: OperationQueue = {
        let q = OperationQueue()
        q.maxConcurrentOperationCount = 1
        return q
    }()

    // override this for de-duping
    // NOTE: that this is happening on background thread
    // NOTE: handler is responsible for saving context
    open func handleInsert(backgroundContext _: NSManagedObjectContext,
                           entityName _: String,
                           objectID _: NSManagedObjectID,
                           storeID _: String)
    {
        fatalError("You must override handleInsert()")
    }

    // MARK: - Helpers

    public let logger = Logger(subsystem: Bundle.main.bundleIdentifier!,
                               category: String(describing: BaseCoreDataStack.self))

    // MARK: - Not used yet

    //    public private(set) lazy var backgroundContext: NSManagedObjectContext = {
    //        precondition(Thread.isMainThread)
    //        let bc = container.newBackgroundContext()
    //        bc.transactionAuthor = appTransactionAuthorName
    //        bc.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    //        return bc
    //    }()

    //    lazy var model: NSManagedObjectModel = {
    //        let bundle = Bundle.module
    //        let modelURL = bundle.url(forResource: modelName, withExtension: ".momd")!
    //        return NSManagedObjectModel(contentsOf: modelURL)!
    //    }()
}
