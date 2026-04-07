# Tracker-Catalog

Simple MVVM SwiftUI implementation for the Tracker Catalog take-home.

## Task 1 Status

Implemented:
- List loading from a REST-style source using `URLSession` async/await
- Search across name, category, and tags
- Pull-to-refresh
- Loading, empty, and error states
- Details screen with `NavigationStack`

## Project Notes

- The app uses a mock URL host (`https://tracker.local`) intercepted by `URLProtocol`.
- This keeps the data layer realistic (`URLSession`-based) while still being local and self-contained.
- Add `mock_items.json` to your app target resources in Xcode.