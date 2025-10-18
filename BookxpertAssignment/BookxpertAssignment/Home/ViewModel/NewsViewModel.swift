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
}
final class NewsViewModel: NewsViewModelProtocol {

    private let newsService: NewsServiceManagerProtocol

    @Published var articles: [Article] = []

    init(newsService: NewsServiceManager = .init()) {
        self.newsService = newsService
    }
    func fetchNews() async {
        guard let res = await newsService.fetchNews() else { return }
        self.articles = res.articles ?? []
    }
}
