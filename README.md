# EIQLinkify

EIQLinkify designed to handle dynamic links within iOS applications. It includes features for app launch checks, deep link handling, and backend integration to streamline link processing. This guide will cover the integration and usage of EIQLinkify in your project.

## Table of Contents
* [Installation 𝍌](#installation)
* [Setup and Configuration ⚙️](#setup-and-configuration)
* [Requirements 🧪](#requirements)

---

## Installation

### Adding EIQLinkify via Swift Package Manager

* In Xcode, select your project and navigate to **File > Add Package Dependencies**.

* In the search bar, enter the repository URL for EIQLinkify:
    
     `https://github.com/loodos/enliq-linkify-ios.git`

* Specify an available version: 
     
     `1.0.0`

* Select `Up to Next Major` with current available version

## Setup and Configuration

After installing the package, initialize EIQLinkify in your application’s `AppDelegate` to manage app launch states and enable deep linking.

This dynamic link flow has two stages. If the universal linking is not used these stages start with opening the EIQLinkify web page, which then opens the relevant content depending on whether the application is installed. Otherwise, the application opens with universal link interaction. The stages are detailed below:

**1. Application is not installed:**
    
When the user clicks the dynamic link, it can open the App Store page of your application. After the application is installed and opened, EIQLinkify checks for the presence of any active dynamic link for the device. This step handles the situation by retrieving the required baseURL value from the EIQLinkify connection services. ([Explained on Step 1](#step-1-configure-EIQLinkify-on-app-launch)) 

If there is a pending (not previously opened due to the application being uninstalled) dynamic link, EIQLinkify retrieves this deep link and triggers the application’s designated method to route to it. During this flow, the “App Open” event is sent if the required method is implemented in the project. ([Explained on Step 2](#step-2-handle-incoming-deep-links)) 

**2. Application is already installed:**
    
**2.1 Opening the application with a EIQLinkify's page:**

When the user clicks the dynamic link, the application opens and an “App Open” event is sent to the EIQLinkify system.
    
**2.2 Opening the application with Universal Link:**

If the clicked dynamic link is a pre-defined universal link ([Explained on Step 3-2](#step-3-2-configuring-universal-link-support)) the application is opened directly. Thus, receiving the needed deeplink can be handled with implementing `handleUniversalLink` method. On this flow, not only "App Open" but also "Click" events can be triggered by EIQLinkify. ([Explained on Step 3](#step-3-handle-incoming-universal-links)) 


### Step 1: Configure EIQLinkify on App Launch

his step is necessary for configuring EIQLinkify and checking for the existence of any active dynamic links.

First, the `configure(with baseURLString: String)` method should be called in your `AppDelegate` class within the `application(_:didFinishLaunchingWithOptions:)` method. This method requires the base URL value needed for your app’s configuration.

Here is an example implementation:

```swift
// Importing the library
import EIQLinkify

class AppDelegate: UIResponder, UIApplicationDelegate {
 
    func application(
         _ application: UIApplication,
         didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Calling the configuration method of `EIQLinkify` with the base URL string value for backend services
        EIQLinkify.shared.configure(with: "https://example-base-url.com/api")
     
        // Additional setup methods of project...
        return true
    }

}
```

With this configuration, `EIQLinkify` receives the required base URL for backend services. Additionally, calling this method initiates the process of checking for active dynamic links through backend services from the initial app setup stage.

### Step 2: Handle Incoming Deep Links

This step is required to send the “App Open” event within the app. If this method is not called, the “App Open” event will not be triggered.

Similar to Step 1, the public `deeplink(from: URL)` method of `EIQLinkify` must be called to send the event. To implement this, update the `application(_:open:options:)` method in `AppDelegate` with the `deeplink(from: URL)` method.

The `deeplink(from: URL)` method takes the incoming URL in the app and handles the event-sending mechanism. This mechanism works with a query parameter for event. This query parameter of event key is added like that: `&key=Tso19bg67`. EIQLinkify checks the url and it's event key query parameter and sends the "App Open" event.

After this received URL processing, it returns the deep link URL value. You can then use this returned URL to handle deep link routing within your application.

Here is the example implementation:

```swift
// Importing the library
import EIQLinkify

extension AppDelegate {
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        // Process the received deep link URL if it has event key query parameter
        // Example: `appName://redirect?pageName=HOME&key=Tso19bg67`
        if let deeplinkURL = EIQLinkify.shared.deeplink(from: url) {
            // Handle the incoming deeplink URL
            // As the same example URL the returning URL will be: `appName://redirect?pageName=HOME`
            // ...
            return true
        }

        // Handle other URL types if needed...
        // ...
        return false
    }
}
```

### Step 3: Handle Incoming Universal Links

#### Step 3-1: Universal Link Flow Methods for Project

When the application’s universal link is triggered, the app opens via the `application(_:continue:restorationHandler:)` method in the `App Delegate`. Within this method, the `handleUniversalLink(with:)` function provided by `EIQLinkify` is used.

This function processes the incoming universal link and converts it into a deep link using the base URL defined by your backend services. After resolving the deep link, if the project infrastructure supports it, “App Open” and “Click” events are also sent.

```swift
// Importing the library
import EIQLinkify

extension AppDelegate {
    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        guard let url = userActivity.webpageURL else { return false }
        // The url value can be like that: "https://example.domain.co/something"
        EIQLinkify.shared.handleUniversalLink(with: url) { deeplinkURL in
            /// Handle the provided deeplink URL value which can be "appScheme://redirect?pageName=SOME_PAGE"
        }

        // Additional setup methods of project...
    }
}
```

#### Step 3-2: Configuring Universal Link Support

For the universal link mechanism to function, the project’s subdomain must be added to the Associated Domains section.

This configuration can be set up in Xcode by navigating to:
Xcode → Main Project Target → Signing & Capabilities → Associated Domains.

Additionally, you must configure the `.well-known/apple-app-site-association` file on the subdomain with the appropriate JSON structure required by Apple. This ensures the domain is correctly associated with your application.

For more details, refer to the [Apple Developer Documentation](https://developer.apple.com/documentation/xcode/supporting-associated-domains).

---

### Step 4: Resolve Deeplink from Web URL

`EIQLinkify` provides a method called `handleAppIndex(with:completion:)` to resolve a known web URL into its corresponding native deeplink. This method is useful when you have a web URL (e.g., from a push notification or browser) and want to determine its associated in-app deep link.

```swift
EIQLinkify.shared.handleAppIndex(with: webURL) { deeplinkURL in
    // Handle resolved deeplink URL, for example:
    // deeplinkURL => "appScheme://redirect?pageName=HOME"
}
```

Internally, this method sends a request to the backend (`/app-index` endpoint), retrieves the list of known iOS deep link mappings, and searches for a `webUrl` that matches the provided URL. If a match is found, it returns the associated deep link as `URL?`. If no match is found or the request fails, the completion handler returns `nil`.

### Step 4.1: Resolve Deeplink from Web URL

`EIQLinkify` also offers a helper method called `getAppIndex(completion:)` to retrieve the full list of iOS-specific web/deeplink mappings from the App Index endpoint.

```swift
EIQLinkify.shared.getAppIndex { iosUrls in
    // Use the list of EIQDeeplinkURLS to inspect or match manually if needed
}
```

Use this method when you want to access the complete mapping data from backend for custom logic or pre-fetching purposes.

---

### Step 5: Basket Event

`sendBasketEvent` allows sending basket-related events (e.g., add to basket, order success) to the backend for analytics and tracking.

```swift
/// Sends a basket event to the backend with the provided basket details.
///
/// - Parameters:
///   - basketId: The unique identifier of the basket.
///   - totalAmount: Total amount for the event. Use full basket total if `status` is `.orderSuccess`; otherwise use product's total.
///   - status: The type of basket event (`EIQLinkifyBasketEventType`).
///   - products: Array of `EIQLinkifyBasketItem` representing the items in the basket.
///
/// - Warning: If the event key is invalid or missing, no event will be sent and a debug message will be logged. Additionally, `totalAmount` must represent the total basket amount when `status` is `.orderSuccess`, otherwise it should represent the individual product's total amount.
func sendBasketEvent(
    basketId: String,
    totalAmount: Double,
    status: EIQLinkifyBasketEventType,
    products: [EIQLinkifyBasketItem]
)
```

### Usage Example

```swift
let deeplinkURL = URL(string: "https://example.com?eiqKey=12345")
EIQLinkify.shared.sendBasketEvent(
    basketId: "basket_001",
    totalAmount: 199.99,
    status: .orderSuccess,
    products: [
        EIQLinkifyBasketItem(id: "sku_001", name: "T-Shirt", quantity: 2, price: 49.99, totalAmount: 99.98),
        EIQLinkifyBasketItem(id: "sku_002", name: "Shoes", quantity: 1, price: 99.99, totalAmount: 99.99)
    ]
)
```


## Requirements

- iOS 13.0+
- Swift 5.9+
