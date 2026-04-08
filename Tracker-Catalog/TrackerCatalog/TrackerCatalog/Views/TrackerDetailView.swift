import SwiftUI

struct TrackerDetailView: View {
    let item: TrackerItem
    @ObservedObject var viewModel: TrackerListViewModel

    var body: some View {
        List {
            Section("Overview") {
                LabeledContent("Name", value: item.name)
                LabeledContent("Category", value: item.category)
                LabeledContent("Status", value: item.status.rawValue.capitalized)
                LabeledContent("Summary", value: item.summary)
                LabeledContent("Details", value: item.details)
            }

            Section("Tags") {
                Text(item.tags.joined(separator: ", "))
            }

            if let specs = item.specs {
                Section("Specs") {
                    LabeledContent("Battery", value: specs.battery)
                    LabeledContent("Connectivity", value: specs.connectivity.joined(separator: ", "))
                    LabeledContent("Dimensions", value: specs.dimensions)
                }
            }
        }
        .navigationTitle(item.name)
        .toolbar {
            Button {
                viewModel.toggleFavorite(item)
            } label: {
                Image(systemName: viewModel.isFavorite(item) ? "star.fill" : "star")
                    .foregroundStyle(.yellow)
            }
            .accessibilityLabel(viewModel.isFavorite(item) ? "Remove Favorite" : "Add Favorite")
        }
    }
}
