//
//  AppConfig.swift
//  BookxpertAssignment
//
//  Created by Dipak Makwana on 17/10/25.
//

import Foundation
struct AppConfig {
    static let baseURL = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String ?? ""
    static let newsApiKey = Bundle.main.object(forInfoDictionaryKey: "NEWS_API_KEY") as? String ?? ""
    static let environment = Bundle.main.object(forInfoDictionaryKey: "ENVIRONMENT") as? String ?? ""
}
