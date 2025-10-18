import Foundation

/// A lightweight disk cache for the latest fetched news response.
/// Uses JSON files in the app's caches directory, suitable for offline reads.
struct ArticleCache {
    private static let fileName = "news_response_cache.json"

    /// File URL in Caches directory for storing the cached response
    private static var fileURL: URL {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return caches.appendingPathComponent(fileName)
    }

    /// Persist a NewsResponse to disk.
    static func save(_ response: NewsResponse) {
        do {
            let data = try JSONEncoder().encode(response)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            #if DEBUG
            print("ArticleCache save error:", error)
            #endif
        }
    }

    /// Load the cached NewsResponse from disk, if present.
    static func load() -> NewsResponse? {
        let url = fileURL
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        do {
            let data = try Data(contentsOf: url)
            let response = try NewsDecoding.decodeResponse(from: data)
            return response
        } catch {
            #if DEBUG
            print("ArticleCache load error:", error)
            #endif
            return nil
        }
    }

    /// Remove the cached file. Safe to call even if no file exists.
    static func clear() {
        let url = fileURL
        if FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.removeItem(at: url)
        }
    }
}
