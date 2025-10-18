import Foundation

/// A lightweight Core Data-backed cache for the latest fetched news response.
/// Stores the JSON payload in a single-row entity `CachedNews` for offline reads.
struct ArticleCache {
    /// Persist a NewsResponse to Core Data as JSON payload.
    static func save(_ response: Article) {
        do {
          ///  let data = try JSONEncoder().encode(response)
            try NewsCacheStore.shared.saveLatest(response)
        } catch {
            #if DEBUG
            print("ArticleCache save error:", error)
            #endif
        }
    }

    /// Load the cached NewsResponse from Core Data, if present.
    static func load() -> [Article]? {
        do {
            if let articles = try NewsCacheStore.shared.loadLatest() {
                //let response = try NewsDecoding.decodeResponse(from: data)
                return articles
            }
            return nil
        } catch {
            #if DEBUG
            print("ArticleCache load error:", error)
            #endif
            return nil
        }
    }

    /// Load the cached NewsResponse from Core Data, if present.
    static func loadBookMark() -> [Article]? {
        do {
            if let articles = try NewsCacheStore.shared.loadLatest() {
                //let response = try NewsDecoding.decodeResponse(from: data)
                return articles
            }
            return nil
        } catch {
            #if DEBUG
            print("ArticleCache load error:", error)
            #endif
            return nil
        }
    }

    /// Remove the cached payload.
    static func clear() {
        do {
            try NewsCacheStore.shared.clear()
        } catch {
            #if DEBUG
            print("ArticleCache clear error:", error)
            #endif
        }
    }

    static func updateBookmark(id: String, isBookmarked: Bool) {
        do {
            guard var articles = try NewsCacheStore.shared.loadLatest() else { return }
          //  let response = try NewsDecoding.decodeResponse(from: data)
         //   var updated = response
           // var articles = updated.articles ?? []

            if let idx = articles.firstIndex(
                where: { $0.id == id }) {
                articles[idx].isBookmarked = isBookmarked
                try NewsCacheStore.shared.saveLatest(articles[idx])
            } else {
                return
            }
          //  updated = NewsResponse(status: response.status, totalResults: response.totalResults, articles: articles)
           /// let data2 = try JSONEncoder().encode(updated)

        } catch {
            #if DEBUG
            print("ArticleCache updateBookmark error:", error)
            #endif
        }
    }
}
