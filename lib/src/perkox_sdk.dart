import 'dart:async';
import 'models/perkox_config.dart';
import 'models/perkox_options.dart';
import 'models/perkox_reward.dart';
import 'platform/perkox_platform_interface.dart';

/// Main static entry point for the Perkox Offerwall SDK.
class PerkoxSDK {
  static String _appId = '';
  static String _sdkKey = '';
  static String _playerId = '';
  static bool _beta = false;
  static bool _isInitialized = false;

  static final List<StreamSubscription<PerkoxReward>> _rewardSubscriptions = [];
  static final List<StreamSubscription<void>> _closeSubscriptions = [];

  /// 1. INIT: Initializes the Perkox Flutter SDK.
  /// Passes configuration to native Android/iOS SDK bridges.
  static Future<bool> init({
    required String appId,
    required String sdkKey,
    String? playerId,
    bool beta = false,
  }) async {
    _appId = appId.trim();
    _sdkKey = sdkKey.trim();
    _playerId = (playerId ?? '').trim();
    _beta = beta;
    _isInitialized = true;

    return await PerkoxPlatform.instance.initSDK(
      appId: _appId,
      sdkKey: _sdkKey,
      playerId: _playerId,
      beta: _beta,
    );
  }

  /// Initializes the Perkox SDK using a [PerkoxInitConfig] configuration object.
  static Future<bool> initFromConfig(PerkoxInitConfig config) async {
    return await init(
      appId: config.appId,
      sdkKey: config.sdkKey,
      playerId: config.playerId,
      beta: config.beta,
    );
  }

  /// 2. LOGIN / SET USER: Updates the active Player ID / User ID in the SDK.
  static Future<bool> setUserId(String playerId) async {
    _playerId = playerId.trim();
    return await PerkoxPlatform.instance.setUserId(_playerId);
  }

  /// 3. SHOW OFFERWALL: Displays the Native Offerwall UI using native bridges.
  static Future<bool> showOfferwall({
    String? appId,
    String? sdkKey,
    String? playerId,
    bool? beta,
  }) async {
    final effectiveAppId = (appId ?? _appId).trim();
    final effectiveSdkKey = (sdkKey ?? _sdkKey).trim();
    final effectivePlayerId = (playerId ?? _playerId).trim();
    final effectiveBeta = beta ?? _beta;

    if (effectiveAppId.isEmpty || effectiveSdkKey.isEmpty) {
      // ignore: avoid_print
      print('[Perkox SDK] Error: appId and sdkKey are required before showing offerwall.');
      return false;
    }

    if (effectivePlayerId.isEmpty) {
      // ignore: avoid_print
      print('[Perkox SDK] Warning: playerId is empty. Make sure user is logged in or playerId is set.');
    }

    return await PerkoxPlatform.instance.showOfferwall(
      appId: effectiveAppId,
      sdkKey: effectiveSdkKey,
      playerId: effectivePlayerId,
      beta: effectiveBeta,
    );
  }

  /// Shows the offerwall with an optional [PerkoxOfferwallOptions] object.
  static Future<bool> showOfferwallWithOptions([PerkoxOfferwallOptions? options]) async {
    return await showOfferwall(
      appId: options?.appId,
      sdkKey: options?.sdkKey,
      playerId: options?.playerId,
      beta: options?.beta,
    );
  }

  /// 4. EVENTS: Subscribe to reward events.
  /// Returns a [StreamSubscription] which can be cancelled when done.
  static StreamSubscription<PerkoxReward> onReward(void Function(PerkoxReward reward) callback) {
    final subscription = PerkoxPlatform.instance.onRewardStream.listen(
      callback,
      onError: (err) {
        // ignore: avoid_print
        print('[Perkox SDK] Exception in onReward stream: $err');
      },
    );
    _rewardSubscriptions.add(subscription);
    return subscription;
  }

  /// 4. EVENTS: Subscribe to offerwall close / dismissal events.
  /// Returns a [StreamSubscription] which can be cancelled when done.
  static StreamSubscription<void> onClose(void Function() callback) {
    final subscription = PerkoxPlatform.instance.onCloseStream.listen(
      (_) => callback(),
      onError: (err) {
        // ignore: avoid_print
        print('[Perkox SDK] Exception in onClose stream: $err');
      },
    );
    _closeSubscriptions.add(subscription);
    return subscription;
  }

  /// Direct access to the Broadcast Stream of reward events.
  static Stream<PerkoxReward> get rewardStream => PerkoxPlatform.instance.onRewardStream;

  /// Direct access to the Broadcast Stream of close events.
  static Stream<void> get closeStream => PerkoxPlatform.instance.onCloseStream;

  /// 5. CONFIG: Updates SDK configuration at runtime.
  static void setConfig({
    String? appId,
    String? sdkKey,
    String? playerId,
    bool? beta,
  }) {
    if (appId != null) _appId = appId.trim();
    if (sdkKey != null) _sdkKey = sdkKey.trim();
    if (playerId != null) setUserId(playerId);
    if (beta != null) _beta = beta;
  }

  /// Returns the current configured App ID.
  static String getAppId() => _appId;

  /// Returns the current configured SDK Key.
  static String getSdkKey() => _sdkKey;

  /// Returns the current configured Player ID.
  static String getPlayerId() => _playerId;

  /// Returns whether beta mode is enabled.
  static bool isBeta() => _beta;

  /// Returns whether the SDK has been initialized.
  static bool isInitialized() => _isInitialized;

  /// Cleans up all active event subscriptions.
  static void removeAllListeners() {
    for (final sub in _rewardSubscriptions) {
      sub.cancel();
    }
    _rewardSubscriptions.clear();

    for (final sub in _closeSubscriptions) {
      sub.cancel();
    }
    _closeSubscriptions.clear();
  }
}
