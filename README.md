# Tracker-Catalog

A simple catalog app built with SwiftUI (iOS 16+) that allows users to browse, search, and view device details.

Requirements:
iOS 16+
Xcode 15+

Getting Started:
-Clone the repository
-Open the project in Xcode
-Ensure mock_items.json is added to the app target
-Build and run on simulator or device

Features:
-Browse list of devices
-View item details
-Search (name, category, tags)
-Pull-to-refresh
-Loading, empty, and error states
-Favorites persistence across app launches

Notes
- The app uses a mock URL host (`https://tracker.local`) intercepted by `URLProtocol`.
- This keeps the data layer realistic (`URLSession`-based) while still being local and self-contained.
- Add `mock_items.json` to your app target resources in Xcode.
