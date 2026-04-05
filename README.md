# Budget iOS

Native iOS app for the Budget app, built with Swift/SwiftUI (MVVM).

## Requirements

- Xcode 15+
- iOS 17+
- Swift 5.9+

## Setup

1. Open `BudgetApp/BudgetApp.xcodeproj` in Xcode
2. Update `Config.swift` with your API base URL
3. Build and run on a simulator or device

## Install via AltStore

1. Build in Xcode: Product > Archive > Distribute App > Ad Hoc > Export `.ipa`
2. Install AltServer on your Mac (https://altstore.io)
3. Install AltStore on your iPhone via AltServer (USB required first time)
4. Open AltStore > My Apps > "+" > select the `.ipa` file
5. AltStore auto-renews the 7-day signing if your Mac is on the same Wi-Fi

Alternative: Use SideStore for renewal without a Mac (via WireGuard).
