//
//  MockNewsViewModel.swift
//  BookxpertAssignmentTests
//
//  Created by Dipak Makwana on 19/10/25.
//

import Foundation
@testable import BookxpertAssignment
internal import Combine


#if TESTING_FALLBACKS
// Lightweight fallbacks to match app models' shape when the main module types are unavailable in tests.
struct Article: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let description: String?
    // Common fields used by many News APIs; provide defaults so tests can construct easily.
    let author: String?
    let url: String?
    let urlToImage: String?

    init(title: String, description: String?, author: String? = nil, url: String? = nil, urlToImage: String? = nil) {
        self.title = title
        self.description = description
        self.author = author
        self.url = url
        self.urlToImage = urlToImage
    }
}

struct NewsResponse: Equatable {
    let status: String?
    let totalResults: Int?
    let articles: [Article]?

    init(status: String? = nil, totalResults: Int? = nil, articles: [Article]? = nil) {
        self.status = status
        self.totalResults = totalResults
        self.articles = articles
    }
}
#endif

protocol NewsServiceManagerProtocol {
    func fetchNews() async throws -> NewsResponse?
}

// Make the mock a class; simple and mutable.
// Use a reference type for the ViewModel so we don't need mutating methods under @MainActor tests.
@MainActor
final class MockNewsViewModel: NewsViewModelProtocol  {

    enum MockError: Error {
        case fetchFailed
    }

    var result: Result<[Article]?, Error> = .success([])
    @Published var articles: [BookxpertAssignment.Article] = []
    @Published var filteredArticles: [BookxpertAssignment.Article] = []
    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false

    func fetchNews() async {
        switch result {
        case .success(let response):
            self.articles = response ?? []
        case .failure(let error):
            self.errorMessage = error.localizedDescription
        }
    }
    func updateBookmark(index: Int, isSearching: Bool) {
        if isSearching {
            filteredArticles = Article.updatedBookMark
        }
        else {
            articles = Article.updatedBookMark
        }
    }
    func filterNews(_ query: String) {
        if query.isEmpty {
            filteredArticles = articles
        }
        else {
            filteredArticles = Article.test
        }
    }
}

