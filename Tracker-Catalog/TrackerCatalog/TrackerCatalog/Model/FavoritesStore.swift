import Foundation

protocol FavoritesStoreType {
    func loadFavoriteIDs() -> Set<String>
    func saveFavoriteIDs(_ ids: Set<String>)
}

final class FavoritesStore: FavoritesStoreType {
    private let defaults: UserDefaults
    private let key = "favorite_tracker_ids"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadFavoriteIDs() -> Set<String> {
        let ids = defaults.stringArray(forKey: key) ?? []
        return Set(ids)
    }

    func saveFavoriteIDs(_ ids: Set<String>) {
        defaults.set(Array(ids), forKey: key)
    }
}
