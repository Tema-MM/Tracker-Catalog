import Foundation

final class MockSessionFactory {
    static func makeSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockAPIURLProtocol.self]
        return URLSession(configuration: config)
    }
}

final class MockAPIURLProtocol: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool {
        request.url?.host == "tracker.local"
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        Task {
            do {
                try await Task.sleep(nanoseconds: 300_000_000)
                try respond()
            } catch {
                client?.urlProtocol(self, didFailWithError: error)
            }
        }
    }

    override func stopLoading() {}

    private func respond() throws {
        guard let url = request.url else {
            throw APIError.invalidResponse
        }

        let allItems = try Self.loadListItems()
        let path = url.path
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let statusCode: Int
        let responseData: Data

        if path == "/items" {
            statusCode = 200
            responseData = try encoder.encode(TrackerListResponse(items: allItems))
        } else if path.starts(with: "/items/") {
            let id = String(path.dropFirst("/items/".count))
            if let item = allItems.first(where: { $0.id == id }) {
                statusCode = 200
                responseData = try encoder.encode(item)
            } else {
                statusCode = 404
                responseData = Data()
            }
        } else {
            statusCode = 404
            responseData = Data()
        }

        guard let response = HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"]
        ) else {
            throw APIError.invalidResponse
        }

        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: responseData)
        client?.urlProtocolDidFinishLoading(self)
    }

    private static func loadListItems() throws -> [TrackerItem] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        if let url = Bundle.main.url(forResource: "mock_items", withExtension: "json") {
            let data = try Data(contentsOf: url)
            return try decoder.decode(TrackerListResponse.self, from: data).items
        }

        let fallbackData = Data(Self.fallbackJSON.utf8)
        return try decoder.decode(TrackerListResponse.self, from: fallbackData).items
    }

    private static let fallbackJSON = """
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
          "lastUpdated": "2025-01-18T10:00:00Z",
          "specs": {
            "battery": "240mAh",
            "connectivity": ["BLE"],
            "dimensions": "30x30x8mm"
          }
        },
        {
          "id": "trk-1002",
          "name": "Motion Sense X",
          "category": "Sensors",
          "summary": "Passive infrared motion detector.",
          "details": "Adjustable sensitivity, 2-year battery life.",
          "status": "offline",
          "tags": ["pir", "battery"],
          "lastUpdated": "2025-01-15T08:30:00Z",
          "specs": {
            "battery": "500mAh",
            "connectivity": ["BLE"],
            "dimensions": "48x48x12mm"
          }
        },
        {
          "id": "trk-1003",
          "name": "Enviro Monitor",
          "category": "Sensors",
          "summary": "Temperature and humidity tracker.",
          "details": "Calibrated probes with alert thresholds.",
          "status": "active",
          "tags": ["temperature", "humidity"],
          "lastUpdated": "2025-01-10T13:45:00Z",
          "specs": {
            "battery": "600mAh",
            "connectivity": ["BLE", "WiFi"],
            "dimensions": "60x45x14mm"
          }
        }
      ]
    }
    """
}
