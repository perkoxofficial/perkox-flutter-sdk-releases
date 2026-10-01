# Perkox Flutter SDK

The official **Perkox Offerwall SDK** for Flutter. Monetize your Flutter applications with dynamic, high-paying rewarded offers for Android and iOS.

---

## 📦 Features

- 🚀 **High Performance:** Lightweight native bridge for zero overhead.
- 📱 **Multiplatform:** Full native support for Android (AAR) and iOS (XCFramework).
- 🛡️ **Anti-Fraud Security:** Automatically detects emulators, rooted devices, VPNs, and tampering with 35+ collected parameters.
- 💰 **Real-time Rewards:** Direct callback and stream listeners for rewarded points.
- 🎨 **Modern API:** Supports both Static (`PerkoxSDK`) and Instance (`PerkoxOfferwall`) integration patterns.

---

## 📥 Installation

Add `perkox_flutter_sdk` to your `pubspec.yaml`:

```yaml
dependencies:
  perkox_flutter_sdk:
    git:
      url: https://github.com/perkoxofficial/perkox-flutter-sdk-releases.git
      ref: v2.0.0
```
*(Or via path if linking locally: `perkox_flutter_sdk: { path: ../perkox-flutter-sdk }`)*

---

## ⚙️ Platform Configuration

### 🤖 Android Setup

1. In `android/app/build.gradle`:
   - Set `minSdkVersion` to at least **21** (Android 5.0+).
   - Ensure `applicationId` matches the **Package ID** registered in your [Perkox Publisher Dashboard](https://pub.perkox.com).

2. In `android/app/src/main/AndroidManifest.xml`, ensure internet permission:
   ```xml
   <uses-permission android:name="android.permission.INTERNET" />
   <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
   ```

### 🍏 iOS Setup

1. In `ios/Podfile`:
   - Set platform to iOS 13.0 or higher:
     ```ruby
     platform :ios, '13.0'
     ```
2. Ensure your **Bundle Identifier** (`PRODUCT_BUNDLE_IDENTIFIER`) in Xcode matches the Package ID registered in your Perkox Dashboard.

---

## 🚀 Quick Start

### 1. Initialize the SDK

Call `PerkoxSDK.init` early in your app lifecycle (e.g. in `main()` or initial screen):

```dart
import 'package:perkox_flutter_sdk/perkox_flutter_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PerkoxSDK.init(
    appId: "YOUR_APP_ID",
    sdkKey: "YOUR_SDK_KEY",
    playerId: "user_12345", // Unique identifier for the player
    beta: false, // Set to true for test mode
  );

  runApp(const MyApp());
}
```

---

### 2. Set / Update User ID

Update the Player ID dynamically whenever a user logs in:

```dart
await PerkoxSDK.setUserId("user_98765");
```

---

### 3. Display the Offerwall

#### Option A: Static Method
```dart
final bool launched = await PerkoxSDK.showOfferwall();
if (!launched) {
  print("Failed to launch Offerwall");
}
```

#### Option B: Hybrid Instance API
```dart
final offerwall = PerkoxOfferwall.init(
  "YOUR_APP_ID",
  "YOUR_SDK_KEY",
  "user_12345",
  false, // beta
);

offerwall.onReward = (PerkoxReward reward) {
  print("Reward earned: ${reward.amount} pts for ${reward.playerId} (TxID: ${reward.txid})");
};

offerwall.onClose = () {
  print("Offerwall was closed");
};

await offerwall.show();
```

---

### 4. Listen for Rewards & Dynamic Payloads

Subscribe to real-time and offline rewards anywhere in your application. Server fields (`click_id`, `cid`, `offer_id`, `sub1`..`sub5`) are **100% dynamically preserved**:

```dart
// Stream listener for rewards
final rewardSub = PerkoxSDK.onReward((PerkoxReward reward) {
  print("Earned: ${reward.amount} (Status: ${reward.status})");
  print("TxID: ${reward.txid}");
  
  // Access any dynamic server/advertiser parameter directly
  final clickId = reward["click_id"];
  final offerId = reward["offer_id"];
  print("Attributed Click: $clickId, Offer: $offerId");
  print("Full raw payload: ${reward.raw}");
});

// Listener for Offerwall dismissal
final closeSub = PerkoxSDK.onClose(() {
  print("Offerwall closed");
});

// Cancel subscription when disposing
@override
void dispose() {
  rewardSub.cancel();
  closeSub.cancel();
  super.dispose();
}
```

---

### ⚡ 5. Offline & Pending Rewards Auto-Sync

When a player finishes an offer while the Flutter app was closed or suspended:

1. **Automatic Sync:** Calling `PerkoxSDK.showOfferwall()` or `offerwall.show()` automatically queries for unclaimed rewards, dispatches them to `onReward`, and acknowledges receipt (`POST /rewards/claim`) to prevent duplicate rewards.
2. **Explicit Manual Sync:** You can also check for rewards on startup without opening the offerwall:

```dart
final List<PerkoxReward> pendingRewards = await PerkoxSDK.syncPendingRewards(
  appId: "YOUR_APP_ID",
  sdkKey: "YOUR_SDK_KEY",
  playerId: "user_12345",
);

for (final r in pendingRewards) {
  print("Synced offline reward: ${r.amount} (TxID: ${r.txid})");
}
```

---

## 🔒 Package ID Matching Rule

The backend validates traffic strictly by `app_id`, `sdk_key`, and `package_id`:
- **Android:** `applicationId` in `build.gradle` must match the registered App Package ID.
- **iOS:** `bundleIdentifier` in Xcode must match the registered App Package ID.

---

## 📄 License

MIT License © [Perkox](https://perkox.com)
