//
//  NewsViewModelTests.swift
//  BookxpertAssignmentTests
//
//  Created by Dipak Makwana on 19/10/25.
//

import Testing
@testable import BookxpertAssignment

@MainActor
@Suite
struct NewsViewModelTests {
   // var newsService: MockNewsService!
    var viewModel: MockNewsViewModel!

    mutating func setUp(result: Result<[Article]?, Error>) {
        viewModel = MockNewsViewModel()
        viewModel.result = result
    }

    @Test
    mutating func fetchNewsSuccessPopulatesArticles() async {
        let expectedArticles = [
            Article(
                author: "Author-1",
                title: "Title-1",
                url: "https://test.com",
                urlToImage: "https://test.com",
                isBookmarked: false),
            Article(author: "Author-2", title: "Title-2", url: "https://test2.com", urlToImage: "https://test2.com",isBookmarked: false)
        ]
        setUp(result: .success(expectedArticles))
        await viewModel.fetchNews()
        #expect(viewModel.articles == expectedArticles)
        #expect(viewModel.errorMessage == nil)
    }
    @Test
    mutating func fetchNewsFailureSetsErrorMessage() async {
        setUp(result: .failure(MockNewsViewModel.MockError.fetchFailed))
        await viewModel.fetchNews()
        #expect(viewModel.articles.isEmpty)
        #expect(viewModel.errorMessage != nil)
    }

    @Test
    mutating func fetchNewsNilArticlesReturnsEmptyArray() async {
        setUp(result: .success(nil))
        await viewModel.fetchNews()
        #expect(viewModel.articles.isEmpty)
        #expect(viewModel.errorMessage == nil)
    }

    @Test
    mutating func fetchNewsSetsLoadingState() async {
        // Given a response that will succeed
        let expectedArticles = Article.test
        setUp(result: .success(expectedArticles))
        // When fetching starts, isLoading should toggle true then false by completion
        // We can't easily observe the intermediate true without hooks, but we can assert final state is false
        await viewModel.fetchNews()

        #expect(viewModel.isLoading == false)
        #expect(viewModel.articles == expectedArticles)
        #expect(viewModel.errorMessage == nil)
    }

    @Test
    mutating func failureThenSuccessClearsErrorMessage() async {
        // First: fail
        setUp(result: .failure(MockNewsViewModel.MockError.fetchFailed))
        await viewModel.fetchNews()
        #expect(viewModel.errorMessage != nil)

        // Then: succeed, error should be cleared
        let expectedArticles = [
            Article(author: "Author-1", title: "Title-1", url: "https://test.com", urlToImage: "https://test.com")
        ]
        // Recreate VM with success service to simulate next fetch cycle
        setUp(result: .success(expectedArticles))
        await viewModel.fetchNews()

        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.articles == expectedArticles)
    }

    @Test
    mutating func multipleFetchesDoNotDuplicateArticles() async {
        let expectedArticles = [
            Article(author: "Author-1", title: "Title-1", url: "https://test.com", urlToImage: "https://test.com"),
            Article(author: "Author-2", title: "Title-2", url: "https://test2.com", urlToImage: "https://test2.com")
        ]
        setUp(result: .success(expectedArticles))

        await viewModel.fetchNews()
        #expect(viewModel.articles == expectedArticles)

        // Trigger another fetch with the same data
        await viewModel.fetchNews()

        // Expect not duplicated; depending on VM behavior this may just reassign
        #expect(viewModel.articles == expectedArticles)
    }

    @Test
    mutating func emptyArticleFieldsAreHandled() async {
        // Depending on your model, empty strings could be valid; this test ensures VM doesn't crash and passes data through
        let articles = [
            Article(author: nil, title: "", url: "", urlToImage: nil)
        ]
        setUp(result: .success(articles))
        await viewModel.fetchNews()

        #expect(viewModel.articles.count == 1)
        #expect(viewModel.errorMessage == nil)
    }
    @Test()
    mutating func updateBookmarkWhileNotSearching() async {
        let articles: [Article] =  [ .init(author: "No Author",
                                title: "No Title",
                                url: "https://test.com/article1",
                                urlToImage: "https://test.com/image.jpg",
                                           isBookmarked: false)]
        setUp(result: .success(articles))
        viewModel.updateBookmark(index: 3, isSearching: false)
        let expectedArticle: [Article] = [ .init(author: "No Author",
                                                 title: "No Title",
                                                 url: "https://test.com/article1",
                                                 urlToImage: "https://test.com/image.jpg",
                                                 isBookmarked: true)]
        #expect(viewModel.articles == expectedArticle)

    }
    @Test()
    mutating func updateBookmarkWhileSearching() async {
        let articles: [Article] =  [ .init(author: "No Author",
                                title: "No Title",
                                url: "https://test.com/article1",
                                urlToImage: "https://test.com/image.jpg",
                                           isBookmarked: false)]
        setUp(result: .success(articles))
        viewModel.updateBookmark(index: 3, isSearching: true)
        let expectedArticle: [Article] = [ .init(author: "No Author",
                                                 title: "No Title",
                                                 url: "https://test.com/article1",
                                                 urlToImage: "https://test.com/image.jpg",
                                                 isBookmarked: true)]
        #expect(viewModel.filteredArticles == expectedArticle)

    }
    @Test()
    mutating func filterNews() async {
        let articles = Article.test
        setUp(result: .success(articles))
        viewModel.filterNews("Apple")
        #expect(viewModel.filteredArticles.count == 1)
        #expect(viewModel.filteredArticles.first?.title == "Apple releases iPhone 14 Pro Max")
    }
}
