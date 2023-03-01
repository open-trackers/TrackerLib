//
//  BaseCoreDataStack-history.swift
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
    func initStoreRemoteChangeNotification(_ container: NSPersistentContainer) {
        logger.notice("\(#function)")
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(storeRemoteChange(_:)),
            name: .NSPersistentStoreRemoteChange,
            object: container.persistentStoreCoordinator
        )
    }

    func deinitStoreRemoteChangeNotification() {
        logger.notice("\(#function)")
        NotificationCenter.default.removeObserver(self)
    }

    // receiver of notifications, to merge changes from other coordinators
    @objc
    func storeRemoteChange(_: Notification) {
        historyQueue.addOperation { [weak self] in

            // briefly jump back on main queue to start background task
            // (container reference must be on main thread)
            DispatchQueue.main.async {
                self?.container.performBackgroundTask { backgroundContext in
                    backgroundContext.transactionAuthor = self?.appTransactionAuthorName
                    backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

                    self?.processPersistentHistory(backgroundContext)
                }
            }
        }
    }

    // fetch history received since last request
    func processPersistentHistory(_ context: NSManagedObjectContext) {
        guard let htfr = NSPersistentHistoryTransaction.fetchRequest
        else {
            logger.error("\(#function): unable to get history transaction fetch request")
            return
        }
        htfr.predicate = NSPredicate(format: "author != %@", appTransactionAuthorName)

        guard let lastHistoryToken = loadToken() else { return }

        // logger.notice("\(#function): last history token is \(lastHistoryToken.description)")

        let fetchHistoryReq = NSPersistentHistoryChangeRequest.fetchHistory(after: lastHistoryToken)
        fetchHistoryReq.fetchRequest = htfr

        guard let historyResult = (try? context.execute(fetchHistoryReq) as? NSPersistentHistoryResult),
              let history = historyResult.result as? [NSPersistentHistoryTransaction]
        else {
            logger.error("\(#function): unable to get history transactions")
            return
        }

        for transaction in history {
            guard let changes = transaction.changes else { continue }
            for change in changes {
                guard change.changeType == .insert,
                      let entityName = change.changedObjectID.entity.name
                else { continue }

                handleInsert(backgroundContext: context,
                             entityName: entityName,
                             objectID: change.changedObjectID,
                             storeID: transaction.storeID)
            }
        }

        if let lastToken = history.last?.token {
            // logger.debug("Saving token \(lastToken.description)")
            saveToken(lastToken)
        }
    }

    // MARK: - History Token

    func getTokenFileURL(name: String) -> URL {
        let url = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent(name, isDirectory: true)
        if !FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)

            } catch {
                logger.error("\(#function): Could not create persistent container url. \(error)")
            }
        }
        return url.appendingPathComponent("token.data", isDirectory: false)
    }

    func saveToken(_ token: NSPersistentHistoryToken) {
        // logger.notice("\(#function) XXXXXXXXXX")
        guard let data = try? NSKeyedArchiver.archivedData(withRootObject: token, requiringSecureCoding: true)
        else {
            logger.notice("\(#function): Unable to fetch history token.")
            return
        }
        do {
            // logger.debug("\(#function): writing token to \(self.tokenFile.absoluteString).")
            try data.write(to: tokenFileURL)
        } catch {
            logger.error("\(#function): Could not write token data. \(error)")
        }
    }

    func loadToken() -> NSPersistentHistoryToken? {
        do {
            guard FileManager.default.fileExists(atPath: tokenFileURL.path) else { return nil } // ignore noisy log when token file not found
            let data = try Data(contentsOf: tokenFileURL)
            return try NSKeyedUnarchiver.unarchivedObject(ofClass: NSPersistentHistoryToken.self, from: data)
        } catch {
            logger.error("\(#function): Could not read token data. \(error)")
        }
        return nil
    }
}
