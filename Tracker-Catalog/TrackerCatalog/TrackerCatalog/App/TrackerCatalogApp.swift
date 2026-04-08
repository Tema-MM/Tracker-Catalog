//
//  TrackerCatalogApp.swift
//  TrackerCatalog
//
//  Created by DAKARally1 on 2026/04/02.
//

import SwiftUI

@main
struct TrackerCatalogApp: App {
    private let repository: TrackerRepository

    init() {
        let session = MockSessionFactory.makeSession()
        repository = TrackerRepository(apiClient: APIClient(session: session))
    }

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: TrackerListViewModel(repository: repository))
        }
    }
}
