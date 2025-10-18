//
//  CachedNews.swift
//  BookxpertAssignment
//
//  Created by Dipak Makwana on 18/10/25.
//

import Foundation

import CoreData

@objc(CachedNews)
final class CachedNews: NSManagedObject {
    @NSManaged var id: String
    @NSManaged var title: String
    @NSManaged var author: String?
    @NSManaged var imageURL: String?
    @NSManaged var url: String?
    @NSManaged var isBookMark: Bool
}

extension CachedNews {

    static let cacheRequest = NSFetchRequest<CachedNews>(entityName: "CachedNews")

    static func fetchRequest(forID id: String) -> NSFetchRequest<CachedNews> {
        let request = CachedNews.cacheRequest
      //  request.predicate = NSPredicate(format: "id == %@", id)
      //  request.predicate = NSPredicate(format: "id == %@", id)

        request.fetchLimit = 1
        return request
    }
    static func fetchBookmarkRequest(forID id: String) -> NSFetchRequest<CachedNews> {
        let request = CachedNews.cacheRequest
        request.predicate = NSPredicate(format: "id == %@ AND isBookMark == YES", id)
        request.fetchLimit = 1
        return request
    }
}
