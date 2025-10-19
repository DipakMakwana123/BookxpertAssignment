//
//  NewsViewModel.swift
//  BookxpertAssignment
//
//  Created by Dipak Makwana on 17/10/25.
//

import Foundation
import Combine

protocol NewsViewModelProtocol: ObservableObject {
    func fetchNews() async
    var articles: [Article] { get set }
    var filteredArticles: [Article] { get set }
    var errorMessage: String? { get set }
    var isLoading: Bool { get set }
    func filterNews(_ query: String)
    func updateBookmark(index: Int , isSearching: Bool)
}

final class NewsViewModel: NewsViewModelProtocol {
    private let newsService: NewsServiceManagerProtocol
    @Published var articles: [Article] = []
    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false

    var filteredArticles: [Article] = []

    init(newsService: NewsServiceManager = .init()) {
        self.newsService = newsService
    }
    func fetchNews() async {
        defer {
            isLoading = false
        }
        do {
            isLoading = true
            guard let res = try await newsService.fetchNews() else { return }
            self.articles = res.articles ?? []
        }
        catch {
            print(error)
            errorMessage = error.localizedDescription
        }
    }

    func filterNews(_ query: String) {
        if query.isEmpty {
            self.filteredArticles = self.articles
        }
        else {
            let lower = query.lowercased()
            self.filteredArticles = self.articles.filter { article in
                let title = article.title?.lowercased() ?? ""
                let author = article.author?.lowercased() ?? ""
                return title.contains(lower) || author.contains(lower)
            }
        }
    }
    private func getSource(_ isSearching: Bool) ->[Article] {
        return isSearching ? self.filteredArticles : self.articles
    }
    func updateBookmark(index: Int , isSearching: Bool) {
            let currentSource = getSource(isSearching)
            guard currentSource.indices.contains(index) else { return }
            var article = currentSource[index]
            article.isBookmarked = article.isBookmarked == nil ? true : !(article.isBookmarked ?? false)
            // Update backing arrays: first update in viewModel.articles
            if let fullIndex = self.articles.firstIndex(where: { ($0.url ?? $0.title) == (article.url ?? article.title) }) {
                self.articles[fullIndex] = article
            }
            if isSearching {
                self.filteredArticles[index] = article
            }
        updateInCache(for: article)
    }
    private func updateInCache(for article: Article)  {
        ArticleCache.updateBookmark(id: article.id, isBookmarked:  article.isBookmarked ?? false)
    }
}
