//
//  BookmarkViewModel.swift
//  BookxpertAssignment
//
//  Created by Dipak Makwana on 18/10/25.
//

import Combine

protocol BookmarkViewModelProtocol: ObservableObject {
    var bookmarked: [Article] { get }
    func loadBookmarked()
}

final class BookmarkViewModel:  BookmarkViewModelProtocol{
    @Published var bookmarked: [Article] = []

    func loadBookmarked() {
        self.bookmarked = ArticleCache.load() ?? []
    }
}
