import 'dart:async';
import 'models/perkox_config.dart';
import 'models/perkox_reward.dart';
import 'perkox_sdk.dart';

/// Represents a configurable instance of the Perkox Offerwall (Hybrid Approach).
class OfferwallInstance {
  final String appId;
  final String sdkKey;
  final String playerId;
  bool beta;

  /// Callback executed when the user completes an offer and earns a reward.
  void Function(PerkoxReward reward)? onReward;

  /// Callback executed when the user dismisses the Offerwall.
  void Function()? onClose;

  StreamSubscription<PerkoxReward>? _subReward;
  StreamSubscription<void>? _subClose;

  OfferwallInstance({
    required this.appId,
    required this.sdkKey,
    required this.playerId,
    this.beta = false,
  });

  /// Returns the current configuration.
  PerkoxOfferwallConfig getConfig() {
    return PerkoxOfferwallConfig(
      appId: appId,
      sdkKey: sdkKey,
      playerId: playerId,
      beta: beta,
      onReward: onReward,
      onClose: onClose,
    );
  }

  /// Triggers the Native Offerwall UI display.
  Future<bool> show() async {
    _removeListeners();

    if (onReward != null) {
      _subReward = PerkoxSDK.onReward((reward) {
        onReward?.call(reward);
      });
    }

    if (onClose != null) {
      _subClose = PerkoxSDK.onClose(() {
        onClose?.call();
        _removeListeners();
      });
    }

    return await PerkoxSDK.showOfferwall(
      appId: appId,
      sdkKey: sdkKey,
      playerId: playerId,
      beta: beta,
    );
  }

  void _removeListeners() {
    _subReward?.cancel();
    _subReward = null;
    _subClose?.cancel();
    _subClose = null;
  }
}

/// Factory and utility class for managing Perkox Offerwalls.
class PerkoxOfferwall {
  /// Initializes a new Perkox Offerwall instance.
  static OfferwallInstance init(
    String appId,
    String sdkKey,
    String playerId, [
    bool beta = false,
  ]) {
    return OfferwallInstance(
      appId: appId,
      sdkKey: sdkKey,
      playerId: playerId,
      beta: beta,
    );
  }

  /// Creates a new Offerwall instance.
  static OfferwallInstance create(
    String appId,
    String sdkKey,
    String playerId,
  ) {
    return OfferwallInstance(
      appId: appId,
      sdkKey: sdkKey,
      playerId: playerId,
    );
  }

  /// Directly displays the native offerwall.
  static Future<bool> showOfferwall(
    String appId,
    String sdkKey,
    String playerId, [
    bool beta = false,
  ]) async {
    return await PerkoxSDK.showOfferwall(
      appId: appId,
      sdkKey: sdkKey,
      playerId: playerId,
      beta: beta,
    );
  }
}
