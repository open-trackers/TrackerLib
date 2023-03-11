//
//  NSManagedObjectContext-ext.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

public extension NSManagedObjectContext {
    /// Batch delete all records for an entity matching the specified predicate/store.
    /// Safe to run on a background context.
    /// NOTE: does NOT save context
    func deleter<T: NSFetchRequestResult>(_: T.Type,
                                          predicate: NSPredicate? = nil,
                                          inStore: NSPersistentStore? = nil) throws
    {
        let entityName = String(describing: T.self)
        let req = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        if let predicate { req.predicate = predicate }
        if let inStore { req.affectedStores = [inStore] }
        let breq = NSBatchDeleteRequest(fetchRequest: req)
        try executeAndMergeChanges(using: breq)
    }

    /// Batch delete all records for an entity for the given objectIDs.
    ///
    /// NOTE: that objectIDs must all be from the same entityType, or you'll
    /// get the "mismatched objectIDs in batch delete initializer" runtime error.
    ///
    /// Safe to run on a background context.
    /// NOTE: does NOT save context
    func deleter(objectIDs: [NSManagedObjectID]) throws {
        guard objectIDs.first != nil else { return }
        let breq = NSBatchDeleteRequest(objectIDs: objectIDs)
        try executeAndMergeChanges(using: breq)
    }

    // via avanderlee
    /// Executes the given `NSBatchDeleteRequest` and directly merges the changes to bring the given managed object context up to date.
    internal func executeAndMergeChanges(using batchDeleteRequest: NSBatchDeleteRequest) throws {
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        let result = try execute(batchDeleteRequest) as? NSBatchDeleteResult
        let changes: [AnyHashable: Any] = [
            NSDeletedObjectsKey: result?.result as? [NSManagedObjectID] ?? [],
        ]
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self])
    }
}

public extension NSManagedObjectContext {
    /// Convenience wrapper for iterating over results from simple fetch request.
    /// Will continue iterating so long as callback returns true
    func fetcher<T: NSFetchRequestResult>(predicate: NSPredicate? = nil,
                                          sortDescriptors: [NSSortDescriptor] = [],
                                          inStore: NSPersistentStore? = nil,
                                          _ each: @escaping (T) throws -> Bool) throws
    {
        let request = makeRequest(T.self,
                                  predicate: predicate,
                                  sortDescriptors: sortDescriptors,
                                  inStore: inStore)
        for result in try fetch(request) as [T] {
            guard try each(result) else { break }
        }
    }

    /// Convenience wrapper for retrieving one record
    func firstFetcher<T: NSFetchRequestResult>(predicate: NSPredicate? = nil,
                                               sortDescriptors: [NSSortDescriptor] = [],
                                               inStore: NSPersistentStore? = nil) throws -> T?
    {
        let request = makeRequest(T.self,
                                  predicate: predicate,
                                  sortDescriptors: sortDescriptors,
                                  inStore: inStore)
        request.fetchLimit = 1
        // req.returnsObjectsAsFaults = false   //TODO does this matter?
        let results: [T] = try fetch(request) as [T]
        return results.first
    }

    /// Convenience wrapper for counting records
    func counter<T: NSFetchRequestResult>(_: T.Type,
                                          predicate: NSPredicate? = nil,
                                          inStore: NSPersistentStore? = nil) throws -> Int
    {
        let request = makeRequest(T.self,
                                  predicate: predicate,
                                  inStore: inStore)
        return try count(for: request)
    }
}
