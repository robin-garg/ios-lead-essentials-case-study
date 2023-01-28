//
//  CoreDataHelpers.swift
//  EssentialFeed
//
//  Created by Apple on 28/01/23.
//

import CoreData

extension NSPersistentContainer {
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
