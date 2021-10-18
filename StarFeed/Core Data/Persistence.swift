//
//  Persistence.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/17/21.
//

import CoreData

struct Persistence {
    static let shared = Persistence()
    
    var container: NSPersistentContainer
    var context: NSManagedObjectContext
    
    init() {
        container = NSPersistentContainer(name: "FreshModel")
        container.loadPersistentStores { desc, error in
            if let error = error {
                fatalError(error.localizedDescription)
            }
        }
        context = container.viewContext
    }
    
    func save() {
        do {
            try context.save()
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
    
    func fetchUser(uid: String) -> CurrentUser? {
        do {
            let request = CurrentUser.fetchRequest() as NSFetchRequest<CurrentUser>
            let predicate = NSPredicate(format: "id CONTAINS '\(uid)'")
            request.predicate = predicate
            let currentUser = try context.fetch(request)
            return currentUser.first
        } catch {
            
        }
         
        return nil
    }
    
    func deleteAll() {
        let storeContainer = container.persistentStoreCoordinator
        for store in storeContainer.persistentStores {
            do { try storeContainer.destroyPersistentStore(at: store.url!, ofType: store.type, options: nil) } catch let error {
                fatalError(error.localizedDescription)
            }
        }
        
    }
}
