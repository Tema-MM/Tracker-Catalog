//
//  ContentView.swift
//  TrackerCatalog
//
//  Created by DAKARally1 on 2026/04/02.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel: TrackerListViewModel

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Tracker Catalog")
                .searchable(text: $viewModel.searchText, prompt: "Search devices")
                .refreshable { await viewModel.refresh() }
                .task { await viewModel.loadIfNeeded() }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView("Loading items...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .empty:
            if #available(iOS 17.0, *) {
                ContentUnavailableView(
                    "No Items",
                    systemImage: "tray",
                    description: Text("Pull to refresh and try again.")
                )
            } else {
                // Fallback on earlier versions
            }

        case let .error(message):
            VStack(spacing: 12) {
                if #available(iOS 17.0, *) {
                    ContentUnavailableView(
                        "Could Not Load",
                        systemImage: "exclamationmark.triangle",
                        description: Text(message)
                    )
                } else {
                    // Fallback on earlier versions
                }
                Button("Retry") {
                    Task { await viewModel.refresh() }
                }
                .buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .loaded:
            if viewModel.filteredItems.isEmpty {
                if #available(iOS 17.0, *) {
                    ContentUnavailableView.search(text: viewModel.searchText)
                } else {
                    // Fallback on earlier versions
                }
            } else {
                List(viewModel.filteredItems) { item in
                    NavigationLink(value: item) {
                        TrackerRowView(
                            item: item,
                            isFavorite: viewModel.isFavorite(item)
                        )
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button {
                            viewModel.toggleFavorite(item)
                        } label: {
                            Label(
                                viewModel.isFavorite(item) ? "Unfavorite" : "Favorite",
                                systemImage: viewModel.isFavorite(item) ? "star.slash" : "star"
                            )
                        }
                        .tint(.yellow)
                    }
                }
                .navigationDestination(for: TrackerItem.self) { item in
                    TrackerDetailView(item: item, viewModel: viewModel)
                }
                .listStyle(.plain)
            }
        }
    }
}

private struct TrackerRowView: View {
    let item: TrackerItem
    let isFavorite: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(item.name)
                    .font(.headline)
                Spacer()
                if isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                }
                Text(item.status.rawValue.capitalized)
                    .font(.caption)
                    .foregroundStyle(item.status == .active ? .green : .secondary)
            }
            Text(item.category)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(item.summary)
                .font(.callout)
                .lineLimit(2)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let repository = TrackerRepository(apiClient: APIClient(session: MockSessionFactory.makeSession()))
    ContentView(viewModel: TrackerListViewModel(repository: repository))
}
