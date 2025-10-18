import Foundation

/// Root response for NewsAPI "everything" endpoint
struct NewsResponse: Codable, Equatable {
    public let status: String?
    public let totalResults: Int?
    public let articles: [Article]?
}

/// An individual article from NewsAPI
struct Article: Codable, Equatable, Identifiable {
    // Provide a stable id synthesized from url (unique per article in NewsAPI)
    public var id: String { url ?? UUID().uuidString }

  //  public let source: Source
    let author: String?
    let title: String?
   // let description: String?
    let url: String?
    let urlToImage: String?
    var isBookmarked: Bool? = false
}


// MARK: - JSON Decoding Helpers

enum NewsDecoding {
    /// Shared JSONDecoder configured for NewsAPI date format (ISO8601 with fractional seconds)
    public static var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        // NewsAPI uses ISO8601 dates, often with fractional seconds.
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let str = try container.decode(String.self)
            if let date = iso.date(from: str) {
                return date
            }
            // Fallback to standard ISO8601 without fractional seconds
            let basicISO = ISO8601DateFormatter()
            basicISO.formatOptions = [.withInternetDateTime]
            if let date = basicISO.date(from: str) {
                return date
            }
            throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Invalid date: \(str)"))
        }
        return decoder
    }()

    /// Decode a NewsResponse from raw Data
    static func decodeResponse(from data: Data) throws -> NewsResponse {
        try decoder.decode(NewsResponse.self, from: data)
    }
}
