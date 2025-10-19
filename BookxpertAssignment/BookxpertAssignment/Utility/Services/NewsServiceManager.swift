//
//  NewsServiceManager.swift
//  BookxpertAssignment
//
//  Created by Dipak Makwana on 17/10/25.
//
import Combine
import Foundation

protocol NewsServiceManagerProtocol {
    func fetchNews() async throws -> NewsResponse?  
}

struct NewsServiceManager: NewsServiceManagerProtocol {
    private var networkManager: NetworkManager

    init(networkManager: NetworkManager = .init()) {
        self.networkManager = networkManager
    }

    private func newsURLComponents() -> URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = AppConfig.baseURL
        components.path = "/v2/everything"
        components.queryItems = [
            URLQueryItem(name: "q", value: "tesla"),
            URLQueryItem(name: "from", value: "2025-09-17"),
            URLQueryItem(name: "sortBy", value: "publishedAt"),
            URLQueryItem(name: "apiKey", value: AppConfig.newsApiKey)
        ]
        return components
    }

    func fetchNews() async throws -> NewsResponse?   {
        guard let url = newsURLComponents().url else {
            // Fall back to cache if URL can't be built
            if let articles = ArticleCache.load() {
                let newsResponse = NewsResponse(
                    status: "ok",
                    totalResults: 999999,
                    articles:articles)
                return newsResponse
            }
            return nil
        }
        print("URL:", url.absoluteString)

        do {
            let data = try await networkManager.fetchData(url)
            let res = try NewsDecoding.decodeResponse(from: data)
            // Persist latest successful response for offline use
            if let articles = res.articles  {
                for article in articles {
                    ArticleCache.save(article)
                }
            }
            return res
        }
        catch let DecodingError.dataCorrupted(context) {
            print("Decoding error: Data corrupted:", context.debugDescription, "path:", context.codingPath)
        }
        catch let DecodingError.keyNotFound(key, context) {
            print("Decoding error: Key not found:", key.stringValue, context.debugDescription, "path:", context.codingPath)
        }
        catch let DecodingError.typeMismatch(type, context) {
            print("Decoding error: Type mismatch:", type, context.debugDescription, "path:", context.codingPath)
        }
        catch let DecodingError.valueNotFound(value, context) {
            print("Decoding error: Value not found:", value, context.debugDescription, "path:", context.codingPath)
        }
        catch {
            print("Other error:", error)
            throw error
        }
        return nil
    }

}
