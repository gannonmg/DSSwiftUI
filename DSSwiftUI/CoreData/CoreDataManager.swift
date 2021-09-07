//
//  CoreDataManager.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 8/5/21.
//

import CoreData

struct CoreDataManager {
    
    static let shared = CoreDataManager()
    let container: NSPersistentContainer
    private var context:NSManagedObjectContext { container.viewContext }
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "DSSwiftUI")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                let error = error as NSError
                fatalError("CoreData init error: \(error), \(error.userInfo)")
            }
        }
    }
    
    func saveCollection(of releases: [DCRelease]) {
 
        let context = container.viewContext
        let collection = (try? context.fetch(ReleaseCollection.fetchRequest()).first) ?? ReleaseCollection(context: context)
        collection.releaseItem?.forEach { item in
            guard let item = item as? NSManagedObject else { return }
            context.delete(item)
        }
        
        let newReleases = releases.map { Release(context: context, release: $0, collection: collection) }
        newReleases.forEach { collection.addToReleaseItem($0) }
        try? context.save()

    }
    
    func fetchCollection() -> [ReleaseViewModel]? {
        let context = container.viewContext
        do {
            let collections:[ReleaseCollection] = try context.fetch(ReleaseCollection.fetchRequest())
            print("Found \(collections.count) collections")
            guard let collection = collections.first,
                  let releaseSet = collection.releaseItem
            else { return nil }
            
            for collection in collections {
                print("Collection has \(collection.releaseItem?.count ?? -1) items")
            }
            
            let storedReleases:[Release] = releaseSet.compactMap { $0 as? Release }
            let viewModels:[ReleaseViewModel] = storedReleases.compactMap { ReleaseViewModel(from: $0) }
            print("Returning content")
            return viewModels
        } catch {
            let error = error as NSError
            print("CoreData fetch error: \(error), \(error.userInfo)")
            return nil
        }
    }
    
    func deleteCollections(emptyOnly: Bool) {
        let context = container.viewContext
        let collections:[ReleaseCollection]? = try? context.fetch(ReleaseCollection.fetchRequest())
        for collection in collections ?? [] {
            let count = collection.releaseItem?.count ?? 0
            if (emptyOnly && count != 0) { continue }
            context.delete(collection)
        }
        
        try! context.save()
    }
    
}
