import Foundation
import Combine 

/// A simple bookmark persistence utility using UserDefaults.
/// 
/// Usage example from a bookmark button action:
/// ```
/// BookmarkStore.shared.toggle(id: article.id)
/// ```
final class BookmarkStore: ObservableObject {
    /// Shared singleton instance
    static let shared = BookmarkStore()
    
    /// Currently bookmarked IDs
    @Published private(set) var ids: Set<String>
    
    private let storageKey = "bookmarked_ids_v1"
    
    private init() {
        if let saved = UserDefaults.standard.array(forKey: storageKey) as? [String] {
            ids = Set(saved)
        } else {
            ids = []
        }
    }
    
    /// Checks whether an ID is bookmarked
    /// - Parameter id: The identifier to check
    /// - Returns: True if bookmarked, false otherwise
    func isBookmarked(id: String) -> Bool {
        ids.contains(id)
    }
    
    /// Toggles bookmark state for the given ID.
    /// If the ID is bookmarked, it will be removed; if not, it will be added.
    /// Automatically persists changes.
    /// - Parameter id: The identifier to toggle
    func toggle(id: String) {
        if ids.contains(id) {
            ids.remove(id)
        } else {
            ids.insert(id)
        }
        persist()
    }
    
    /// Explicitly update bookmark state for the given ID.
    /// - Parameters:
    ///   - id: The identifier to update
    ///   - isBookmarked: The desired bookmark state
    func update(id: String, isBookmarked: Bool) {
        if isBookmarked {
            ids.insert(id)
        } else {
            ids.remove(id)
        }
        persist()
    }
    
    /// Persists current bookmark IDs to UserDefaults
    private func persist() {
        UserDefaults.standard.set(Array(ids), forKey: storageKey)
        UserDefaults.standard.synchronize()
    }
}
