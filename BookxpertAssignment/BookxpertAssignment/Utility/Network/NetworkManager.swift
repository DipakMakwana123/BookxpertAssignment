//
//  NetworkManager.swift
//  BookxpertAssignment
//
//  Created by Dipak Makwana on 17/10/25.
//

import Foundation
protocol NetworkManagerProtocol {
    func fetchData(_ url: URL) async throws -> Data
}

struct NetworkManager: NetworkManagerProtocol {
    func fetchData(_ url: URL) async throws -> Data {
        let urlSession = URLSession.shared
        do {
            let (data, response) = try await urlSession.data(from: url)
            if let http = response as? HTTPURLResponse {
                switch http.statusCode {
                case 200...299:
                    break
                case 401:
                    throw NetworkError.unauthorized
                case 403:
                    throw NetworkError.forbidden
                case 404:
                    throw NetworkError.notFound
                case 500...599:
                    throw NetworkError.serverError(statusCode: http.statusCode)
                default:
                    throw NetworkError.requestFailed(statusCode: http.statusCode)
                }
            }
            guard !data.isEmpty else { throw NetworkError.noData }
            return data
        } catch let error as URLError {
            switch error.code {
            case .timedOut:
                throw NetworkError.timeout
            case .cancelled:
                throw NetworkError.cancelled
            default:
                throw NetworkError.transportError(underlying: error)
            }
        } catch {
            throw NetworkError.transportError(underlying: error)
        }
    }
}
