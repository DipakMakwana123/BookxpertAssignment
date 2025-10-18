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
}
final class NewsViewModel: NewsViewModelProtocol {

    private let newsService: NewsServiceManagerProtocol

    @Published var articles: [Article] = []
    @Published var errorMessage: String? = nil

    var filteredArticles: [Article] = []

    init(newsService: NewsServiceManager = .init()) {
        self.newsService = newsService
    }
    func fetchNews() async {
        do {
            guard let res = try await newsService.fetchNews() else { return }
            self.articles = res.articles ?? []
        }
        catch {
            print(error)
            errorMessage = error.localizedDescription
        }
    }
}
