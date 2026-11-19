<p align="center">
  <img src="https://i.ibb.co/zh0Lrz6J/test.png" alt="Enliq" width="320"/>
</p>

<h1 align="center">EIQLinkify iOS SDK</h1>

<p align="center">
  <a href="https://github.com/loodos/enliq-linkify-ios-sdk/releases/latest"><img src="https://img.shields.io/github/v/release/loodos/enliq-linkify-ios-sdk?label=release&sort=semver" alt="Latest release"/></a>
  <img src="https://img.shields.io/badge/platform-iOS%2015.0%2B-blue.svg" alt="Platform iOS 15.0+"/>
  <a href="https://swift.org/package-manager"><img src="https://img.shields.io/badge/SPM-compatible-brightgreen.svg" alt="Swift Package Manager compatible"/></a>
  <img src="https://img.shields.io/badge/distribution-XCFramework-lightgrey.svg" alt="Binary XCFramework"/>
</p>

<p align="center">
  Dynamic links, deferred deep links, universal links and attribution events<br/>
  for iOS apps powered by the <a href="https://www.enliq.com">Enliq</a> customer engagement platform.
</p>

<p align="center">
  <a href="https://developer.enliq.com"><b>Developer Docs</b></a> ·
  <a href="https://github.com/loodos/enliq-linkify-ios-sdk/releases"><b>Releases</b></a> ·
  <a href="#support"><b>Support</b></a>
</p>

---

## Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [How It Works](#how-it-works)
- [Quick Start](#quick-start)
- [Deep Links](#deep-links)
- [Universal Links](#universal-links)
- [App Index](#app-index)
- [Basket Events](#basket-events)
- [Migrating to 1.2](#migrating-to-12)
- [Support](#support)

## Requirements

| | Minimum |
|---|---|
| iOS | 15.0 |
| Xcode | 16.0 |
| Swift | 5.9 |

The SDK is distributed as a precompiled **binary XCFramework** built with library evolution, so it works with any newer Swift compiler. It has **no third-party dependencies**.

## Installation

### Swift Package Manager

**Xcode:** `File` → `Add Package Dependencies…` → enter the URL below → choose **Up to Next Major Version**.

```
https://github.com/loodos/enliq-linkify-ios-sdk
```

Add the `EIQLinkify` library to your app target.

**Package.swift:**

```swift
dependencies: [
    .package(url: "https://github.com/loodos/enliq-linkify-ios-sdk.git", .upToNextMajor(from: "1.2.0"))
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "EIQLinkify", package: "enliq-linkify-ios-sdk")
        ]
    )
]
```

## How It Works

| Scenario | What happens | Events |
|---|---|---|
| **App not installed** | The link opens the App Store. On first launch, `configure(with:)` asks the Enliq backend for a pending link for this device and routes to it (deferred deep link). | App Open |
| **App installed, opened via the Linkify page** | The app opens with a deep link carrying the `eiqKey` query parameter; `deeplink(from:)` strips it and reports the event. | App Open |
| **App installed, opened via a Universal Link** | The app opens directly; `handleUniversalLink(with:completion:)` resolves the web URL to a deep link. | App Open, Click |

## Quick Start

Configure the SDK as early as possible, in `application(_:didFinishLaunchingWithOptions:)`. This also checks for a pending deferred deep link.

```swift
import EIQLinkify

final class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        EIQLinkify.shared.configure(with: "https://<your-linkify-base-url>/api")
        return true
    }
}
```

The base URL is provided in the Enliq panel for your project.

## Deep Links

Pass every incoming URL to `deeplink(from:)`. If the URL carries the `eiqKey` parameter, the SDK sends the **App Open** event and returns the clean deep link to route to; otherwise it returns `nil`.

```swift
func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
) -> Bool {
    // myapp://redirect?pageName=HOME&eiqKey=Tso19bg67
    if let deeplink = EIQLinkify.shared.deeplink(from: url) {
        // myapp://redirect?pageName=HOME
        router.open(deeplink)
        return true
    }
    return false // not a Linkify URL; handle other URL types here
}
```

> If `deeplink(from:)` is not called, App Open events are not reported.

## Universal Links

### 1. Handle the user activity

```swift
func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
) -> Bool {
    guard let url = userActivity.webpageURL else { return false }

    // https://links.example.com/summer-sale
    EIQLinkify.shared.handleUniversalLink(with: url) { deeplink in
        // myapp://redirect?pageName=CAMPAIGN  (nil if it can't be resolved)
        guard let deeplink else { return }
        router.open(deeplink)
    }
    return true
}
```

The SDK resolves the web URL through the Enliq backend and reports **App Open** and **Click** events.

### 2. Associated Domains

1. In Xcode, open your app target → **Signing & Capabilities** → add **Associated Domains** with `applinks:<your-link-domain>`.
2. Make sure `https://<your-link-domain>/.well-known/apple-app-site-association` lists your app's Team ID and bundle identifier.

See [Supporting associated domains](https://developer.apple.com/documentation/xcode/supporting-associated-domains) for details.

## App Index

Resolve a known web URL (from a push notification, an in-app browser, etc.) to its native deep link:

```swift
EIQLinkify.shared.handleAppIndex(with: webURL) { deeplink in
    // myapp://redirect?pageName=HOME, or nil if there is no mapping
}
```

`getAppIndex(completion:)` fetches the full list of web URL ↔ deep link mappings configured for iOS.

## Basket Events

Report basket activity for attribution:

```swift
EIQLinkify.shared.sendBasketEvent(
    basketId: "basket_001",
    totalAmount: 199.97,
    status: .orderSuccess,
    products: [
        EIQLinkifyBasketItem(id: "sku_001", name: "T-Shirt", quantity: 2, price: 49.99, totalAmount: 99.98),
        EIQLinkifyBasketItem(id: "sku_002", name: "Shoes", quantity: 1, price: 99.99, totalAmount: 99.99)
    ]
)
```

| `status` | `totalAmount` |
|---|---|
| `.addToBasket`, `.removeFromBasket` | Total of the affected product(s) |
| `.orderSuccess` | Total of the whole basket |

Basket events are attributed to the last Linkify link resolved in the current app session. If no Linkify link has been resolved, the call is a no-op.

## Migrating to 1.2

- Minimum deployment target is now **iOS 15.0**.
- Use this repository (`enliq-linkify-ios-sdk`) as the package URL. No access token is needed.
- If you previously used the SDK from source, run **Product → Clean Build Folder** (or delete DerivedData) once after switching.

## Support

- **Integration guides & changelog:** [developer.enliq.com](https://developer.enliq.com)
- **Bug reports:** [GitHub Issues](https://github.com/loodos/enliq-linkify-ios-sdk/issues)
- **Account & panel questions:** contact your Enliq account manager.

---

<p align="center">© Enliq. All rights reserved.</p>
