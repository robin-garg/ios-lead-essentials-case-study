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
    
    public init(storeURL: URL, bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modalName: "FeedStore", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }
    
    public func loadCachedFeed(completion: @escaping RetrievalCompletion) {
        let context = self.context
        context.perform {
            do {
                if let cache = try ManagedCache.find(in: context) {
                    completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
                } else {
                    completion(.empty)
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func insert(_ feed: [EssentialFeed.LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        let context = self.context
        context.perform {
            do {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.feed = ManagedFeedImage.images(from: feed, in: context)
                
                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        completion(nil)
    }
}

private extension NSPersistentContainer {
    enum LoadingError: Swift.Error {
        case modalNotFound
        case failedToLoadPersistentStores(Swift.Error)
    }
    
    static func load(modalName name: String, url: URL, in bundle: Bundle) throws -> NSPersistentContainer {
        guard let modal = NSManagedObjectModel.with(name: name, in: bundle) else {
            throw LoadingError.modalNotFound
        }
        
        let description = NSPersistentStoreDescription(url: url)
        let container = NSPersistentContainer(name: name, managedObjectModel: modal)
        container.persistentStoreDescriptions = [description]
        
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

@objc(ManagedCache)
private class ManagedCache: NSManagedObject {
    
    @NSManaged var timestamp: Date
    @NSManaged var feed: NSOrderedSet
    
    static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
        let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
        request.returnsObjectsAsFaults = false
        return try context.fetch(request).first
    }
    
    static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedCache {
        try find(in: context).map(context.delete)
        return ManagedCache(context: context)
    }
    
    var localFeed: [LocalFeedImage] {
        return feed.compactMap{ ($0 as? ManagedFeedImage)?.local }
    }
}

@objc(ManagedFeedImage)
private class ManagedFeedImage: NSManagedObject {
    
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var cache: ManagedCache
    
    static func images(from localFeed: [LocalFeedImage], in context: NSManagedObjectContext) -> NSOrderedSet {
       return NSOrderedSet(array: localFeed.map { local in
            let managedImage = ManagedFeedImage(context: context)
            managedImage.id = local.id
            managedImage.imageDescription = local.description
            managedImage.location = local.location
            managedImage.url = local.url
            return managedImage
        })
    }
 
    var local: LocalFeedImage {
        return LocalFeedImage(id: id, description: imageDescription, location: location, url: url)
    }
}