import Foundation

protocol TrackerRepositoryType {
    func fetchItems() async throws -> [TrackerItem]
    func fetchItemDetails(id: String) async throws -> TrackerItem
}

final class TrackerRepository: TrackerRepositoryType {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func fetchItems() async throws -> [TrackerItem] {
        try await apiClient.fetchItems()
    }

    func fetchItemDetails(id: String) async throws -> TrackerItem {
        try await apiClient.fetchItemDetails(id: id)
    }
}
