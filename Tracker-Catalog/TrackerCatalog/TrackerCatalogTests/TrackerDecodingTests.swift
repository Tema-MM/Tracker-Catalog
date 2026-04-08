import XCTest
@testable import TrackerCatalog

final class TrackerDecodingTests: XCTestCase {
    func testTrackerListResponseDecodesISO8601Dates() throws {
        let json = """
        {
          "items": [
            {
              "id": "trk-1001",
              "name": "Beacon Pro",
              "category": "Beacons",
              "summary": "Indoor location beacon for micro-positioning.",
              "details": "Battery-powered BLE beacon with configurable intervals.",
              "status": "active",
              "tags": ["ble", "indoor"],
              "lastUpdated": "2025-01-18T10:00:00Z"
            }
          ]
        }
        """

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(TrackerListResponse.self, from: Data(json.utf8))

        XCTAssertEqual(decoded.items.count, 1)
        XCTAssertEqual(decoded.items.first?.id, "trk-1001")
        XCTAssertEqual(decoded.items.first?.status, .active)
    }
}
