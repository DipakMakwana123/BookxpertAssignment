import Foundation
import CoreData


final class NewsCacheStore {
    static let shared = NewsCacheStore()
    
    private init() {
        persistentContainer.loadPersistentStores { [weak self] (storeDescription, error) in
            if let error = error {
                #if DEBUG
                fatalError("Failed to load persistent store: \(error)")
                #endif
            }
            self?.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
            self?.persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        }
    }
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "NewsCache", managedObjectModel: makeModel())
        
        let storeURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("NewsCache.sqlite")
        
        let description = NSPersistentStoreDescription(url: storeURL)
        description.type = NSSQLiteStoreType
        container.persistentStoreDescriptions = [description]
        
        return container
    }()
    
    private func makeModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        
        let entity = NSEntityDescription()
        entity.name = "CachedNews"
        entity.managedObjectClassName = NSStringFromClass(CachedNews.self)

        model.entities = [entity]
        
        return model
    }
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func saveLatest(_ article: Article) throws {
        let request = CachedNews.fetchRequest(forID: "latest")
        do {
            let results = try context.fetch(request)
            let cachedNews = results.first ?? CachedNews(context: context)
            cachedNews.id = article.id
            cachedNews.title = article.title ?? ""
            cachedNews.author = article.author ?? ""
            cachedNews.imageURL = article.urlToImage ?? ""
            cachedNews.isBookMark = article.isBookmarked ?? false
            try context.save()
        } catch {
            throw error
        }
    }
    
    func loadLatest() throws -> [Article]? {
        let request = CachedNews.fetchRequest(forID: "latest")
        do {
            let results = try context.fetch(request)
            if results.isEmpty { return nil }
            let article = Article(
                author: results.first?.author ?? "",
                title: results.first?.title ?? "",
                url: results.first?.url,
                urlToImage: results.first?.imageURL ?? "",
                isBookmarked: results.first?.isBookMark ?? false
            )
            return [article]
        } catch {
            throw error
        }
    }

    func loadBookmark() throws -> [Article]? {
        let request = CachedNews.fetchBookmarkRequest(forID: "latest")
        do {
            let results = try context.fetch(request)

            let article = Article(
                author: results.first?.author ?? "",
                title: results.first?.title ?? "",
                url: results.first?.url,
                urlToImage: results.first?.imageURL ?? "",
                isBookmarked: results.first?.isBookMark ?? false
            )
            return [article]
            //return results as! [Article]
        } catch {
            throw error
        }
    }

    func clear() throws {
        let request = CachedNews.fetchRequest(forID: "latest")
        do {
            let results = try context.fetch(request)
            if let cachedNews = results.first {
                context.delete(cachedNews)
                try context.save()
            }
        } catch {
            throw error
        }
    }

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

