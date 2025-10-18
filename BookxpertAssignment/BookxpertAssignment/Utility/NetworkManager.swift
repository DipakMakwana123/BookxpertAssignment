//
//  NetworkManager.swift
//  BookxpertAssignment
//
//  Created by Dipak Makwana on 17/10/25.
//

import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case requestFailed(statusCode: Int)
    case decodingFailed(underlying: Error? = nil)
    case encodingFailed(underlying: Error? = nil)
    case transportError(underlying: Error)
    case noData
    case timeout
    case cancelled
    case unauthorized                           // 401
    case forbidden                              // 403
    case notFound                               // 404
    case serverError(statusCode: Int)           // 5xx
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL provided was invalid."
        case .requestFailed(let statusCode):
            return "The request failed with status code \(statusCode)."
        case .decodingFailed:
            return "Failed to decode the response."
        case .encodingFailed:
            return "Failed to encode the request body."
        case .transportError(let underlying):
            return "A network transport error occurred: \(underlying.localizedDescription)"
        case .noData:
            return "No data was received from the server."
        case .timeout:
            return "The request timed out."
        case .cancelled:
            return "The request was cancelled."
        case .unauthorized:
            return "You are not authorized to perform this action."
        case .forbidden:
            return "Access to the requested resource is forbidden."
        case .notFound:
            return "The requested resource was not found."
        case .serverError(let statusCode):
            return "The server encountered an error (status code \(statusCode))."
        case .unknown:
            return "An unknown error occurred."
        }
    }
}

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
