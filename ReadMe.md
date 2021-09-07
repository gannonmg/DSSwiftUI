# DSSwiftUI (Discogs Shuffler)

DSSwiftUI is a purely SwiftUI version of my Discogs Shuffler app. This app allows users to store their Discogs vinyl collections on their device, pick a random album from their collection, filter potential albums to "shuffle", and Scrobble their listens by connecting a Last.fm account.

## Setup
Clone the repository onto your machine

You'll need to create both a Discogs and Last.fm application of your own to test the app: 

1. Discogs
    * Create a Disogs account at [discogs.com](https://www.discogs.com/)
    * Register a discogs application in your [developer settings](https://www.discogs.com/settings/developers)
2. last.fm
    * Create a Last.fm account at [last.fm/join](https://www.last.fm/join)
    * Create an api account at [last.fm/api/account/create](https://www.last.fm/api/account/create)

Then, you'll need to add a file to hold your credentials within the application
1. Create a file `Secret.swift` within the API directory
2. Add the following structures to `Secret.swift`:

```swift
struct DCAuthInfo {
    static let client   = "**REDACTED**"
    static let key      = "**REDACTED**"
    static let secret   = "**REDACTED**"
    static let callback = "**REDACTED**"
}

struct LFAuthInfo {
    static let apiKey    = "**REDACTED**"
    static let apiSecret = "**REDACTED**"
}

```

## ToDo
- [x] Setup Discogs login via OAuth
- [x] Retrieve and display user collection in list
- [x] Implement SwiftUI solution for pre-iOS 15 async images
- [x] Retrieve and display release track listing from additional detail API
- [x] Rough initial CoreData implementation
- [x] Implement Searching and Filtering of releases
- [ ] Fix bug where CoreData creates multiple Collections instead of updating the existing one
- [ ] Store Release tracks in CoreData
- [ ] Add welcome screen
- [ ] Smooth out user flow from login to release loading.
- [ ] Add Scrobble button to release detail view
- [ ] Use Matched Geometry Effect to present ReleaseDetailView in style
- [ ] Explore @FetchRequest property wrapper for CoreData
