import Foundation
import Combine

@MainActor
final class TrackerListViewModel: ObservableObject {
    enum ViewState: Equatable {
        case idle
        case loading
        case loaded
        case empty
        case error(String)
    }

    @Published private(set) var items: [TrackerItem] = []
    @Published var searchText = ""
    @Published private(set) var state: ViewState = .idle
    @Published private(set) var favoriteIDs: Set<String>

    private let repository: TrackerRepositoryType
    private let favoritesStore: FavoritesStoreType

    init(
        repository: TrackerRepositoryType,
        favoritesStore: FavoritesStoreType = FavoritesStore()
    ) {
        self.repository = repository
        self.favoritesStore = favoritesStore
        self.favoriteIDs = favoritesStore.loadFavoriteIDs()
    }

    var filteredItems: [TrackerItem] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return items }

        return items.filter { item in
            item.name.lowercased().contains(query)
                || item.category.lowercased().contains(query)
                || item.tags.joined(separator: " ").lowercased().contains(query)
        }
    }

    func loadIfNeeded() async {
        guard state == .idle else { return }
        await loadItems()
    }

    func refresh() async {
        await loadItems(isRefreshing: true)
    }

    func isFavorite(_ item: TrackerItem) -> Bool {
        favoriteIDs.contains(item.id)
    }

    func toggleFavorite(_ item: TrackerItem) {
        if favoriteIDs.contains(item.id) {
            favoriteIDs.remove(item.id)
        } else {
            favoriteIDs.insert(item.id)
        }
        favoritesStore.saveFavoriteIDs(favoriteIDs)
    }

    private func loadItems(isRefreshing: Bool = false) async {
        if !isRefreshing {
            state = .loading
        }

        do {
            let fetched = try await repository.fetchItems()
            items = fetched
            state = fetched.isEmpty ? .empty : .loaded
        } catch {
            if items.isEmpty {
                state = .error(message(for: error))
            } else {
                state = .loaded
            }
        }
    }

    private func message(for error: Error) -> String {
        if let apiError = error as? APIError {
            return apiError.errorDescription ?? "Something went wrong. Please try again."
        }
        return "Something went wrong. Please try again."
    }
}
