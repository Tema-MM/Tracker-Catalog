import Foundation

enum APIError: LocalizedError {
    case invalidResponse
    case notFound
    case httpStatus(Int)
    case decodingFailed
    case networkUnavailable

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "We received an invalid response from the server."
        case .notFound:
            return "The requested item was not found."
        case let .httpStatus(code):
            return "Server returned status code \(code)."
        case .decodingFailed:
            return "We could not read the server data format."
        case .networkUnavailable:
            return "Network is unavailable. Please try again."
        }
    }
}

final class APIClient {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession) {
        self.session = session
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }

    func fetchItems() async throws -> [TrackerItem] {
        let url = URL(string: "https://tracker.local/items")!
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(from: url)
        } catch {
            throw mapTransportError(error)
        }
        try validate(response: response)
        do {
            return try decoder.decode(TrackerListResponse.self, from: data).items
        } catch is DecodingError {
            throw APIError.decodingFailed
        }
    }

    func fetchItemDetails(id: String) async throws -> TrackerItem {
        let url = URL(string: "https://tracker.local/items/\(id)")!
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(from: url)
        } catch {
            throw mapTransportError(error)
        }
        try validate(response: response)
        do {
            return try decoder.decode(TrackerItem.self, from: data)
        } catch is DecodingError {
            throw APIError.decodingFailed
        }
    }

    private func validate(response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200:
            return
        case 404:
            throw APIError.notFound
        default:
            throw APIError.httpStatus(httpResponse.statusCode)
        }
    }

    private func mapTransportError(_ error: Error) -> Error {
        guard let urlError = error as? URLError else { return error }

        switch urlError.code {
        case .notConnectedToInternet, .networkConnectionLost, .cannotFindHost, .cannotConnectToHost:
            return APIError.networkUnavailable
        default:
            return urlError
        }
    }
}
