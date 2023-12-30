//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Apple on 28/01/23.
//

import CoreData

public final class CoreDataFeedStore {
    private static let modalName = "FeedStore"
    private static let model = NSManagedObjectModel.with(name: modalName, in: Bundle(for: CoreDataFeedStore.self))
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    enum StoreError: Swift.Error {
        case modalNotFound
        case failedToLoadPersistentStores(Swift.Error)
    }

    public init(storeURL: URL) throws {
        guard let modal = CoreDataFeedStore.model else {
            throw StoreError.modalNotFound
        }
        
        do {
            container = try NSPersistentContainer.load(name: CoreDataFeedStore.modalName, modal: modal, url: storeURL)
            context = container.newBackgroundContext()
        } catch {
            throw StoreError.failedToLoadPersistentStores(error)
        }
    }
        
    func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
    }
    
    private func cleanupReferencesToPersistantStores() {
        context.performAndWait {
            if let coordinator = self.context.persistentStoreCoordinator {
                try? coordinator.persistentStores.forEach(coordinator.remove)
            }
        }
    }
    
    deinit {
        cleanupReferencesToPersistantStores()
    }
}
