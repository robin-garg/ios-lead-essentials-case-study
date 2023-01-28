//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Apple on 28/01/23.
//

import CoreData

public final class CoreDataFeedStore: FeedStore {
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init(bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modalName: "FeedStore", in: bundle)
        context = container.newBackgroundContext()
    }
    
    public func loadCachedFeed(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
    
    public func insert(_ feed: [EssentialFeed.LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
    }
}

private extension NSPersistentContainer {
    enum LoadingError: Swift.Error {
        case modalNotFound
        case failedToLoadPersistentStores(Swift.Error)
    }
    
    static func load(modalName name: String, in bundle: Bundle) throws -> NSPersistentContainer {
        guard let modal = NSManagedObjectModel.with(name: name, in: bundle) else {
            throw LoadingError.modalNotFound
        }
        
        let container = NSPersistentContainer(name: name, managedObjectModel: modal)
        var loadError: Swift.Error?
        container.loadPersistentStores { loadError = $1 }
        try loadError.map { throw LoadingError.failedToLoadPersistentStores($0) }
        
        return container
    }
}

private extension NSManagedObjectModel {
    static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
        return bundle.url(forResource: name, withExtension: "momd").flatMap { NSManagedObjectModel(contentsOf: $0) }
    }
}

private class ManagedCache: NSManagedObject {
    
    @NSManaged var timestamp: Date
    @NSManaged var feed: NSOrderedSet
}

private class ManagedFeedImage: NSManagedObject {
    
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var cache: ManagedCache
}


