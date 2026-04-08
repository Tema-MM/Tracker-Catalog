import XCTest
@testable import TrackerCatalog

@MainActor
final class TrackerListViewModelTests: XCTestCase {
    func testToggleFavoriteAddsAndRemovesFavoriteID() {
        let item = TrackerItem(
            id: "trk-1001",
            name: "Beacon Pro",
            category: "Beacons",
            summary: "summary",
            details: "details",
            status: .active,
            tags: ["ble"],
            lastUpdated: Date(),
            specs: nil
        )

        let store = InMemoryFavoritesStore()
        let viewModel = TrackerListViewModel(
            repository: MockTrackerRepository(items: [item]),
            favoritesStore: store
        )

        XCTAssertFalse(viewModel.isFavorite(item))
        viewModel.toggleFavorite(item)
        XCTAssertTrue(viewModel.isFavorite(item))
        viewModel.toggleFavorite(item)
        XCTAssertFalse(viewModel.isFavorite(item))
    }
}

private struct MockTrackerRepository: TrackerRepositoryType {
    let items: [TrackerItem]

    func fetchItems() async throws -> [TrackerItem] {
        items
    }

    func fetchItemDetails(id: String) async throws -> TrackerItem {
        items.first(where: { $0.id == id }) ?? items[0]
    }
}

private final class InMemoryFavoritesStore: FavoritesStoreType {
    private var storage = Set<String>()

    func loadFavoriteIDs() -> Set<String> {
        storage
    }

    func saveFavoriteIDs(_ ids: Set<String>) {
        storage = ids
    }
}
