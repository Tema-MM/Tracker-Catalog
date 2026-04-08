import Foundation

struct TrackerListResponse: Codable {
    let items: [TrackerItem]
}

struct TrackerItem: Codable, Identifiable, Equatable, Hashable {
    enum Status: String, Codable {
        case active
        case offline
    }

    struct Specs: Codable, Equatable, Hashable {
        let battery: String
        let connectivity: [String]
        let dimensions: String
    }

    let id: String
    let name: String
    let category: String
    let summary: String
    let details: String
    let status: Status
    let tags: [String]
    let lastUpdated: Date
    let specs: Specs?
}
