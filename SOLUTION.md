Architecture:
-The app follows MVVM with a simple service layer:
-Views: SwiftUI UI components
-ViewModels: Manage state and business logic
-Services:
APIService (networking via URLSession + async/await)
FavoritesService (UserDefaults persistence)


Networking:
-Uses URLSession with async/await
-JSON decoded using Codable with ISO8601 date handling
-Mock API via URLProtocol using local JSON (mock_items.json)


Search:
Search is implemented in the ViewModel and filters across name, category, and tags.
Keeping this logic in the ViewModel ensures separation of concerns and keeps views simple.


State Handling:
-The UI handles:
-Loading
-Success
-Empty results
-Error states


Trade-offs
-Used UserDefaults for simplicity
-Used a mock API layer to keep the app self-contained


Testing
Includes minimal tests for:
JSON decoding
Favorites logic


Notes
- The app uses a mock URL host (`https://tracker.local`) intercepted by `URLProtocol`.
- This keeps the data layer realistic (`URLSession`-based) while still being local and self-contained.
- Add `mock_items.json` to your app target resources in Xcode.
