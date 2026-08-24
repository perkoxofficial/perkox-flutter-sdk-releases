import 'perkox_reward.dart';

/// Configuration object for initializing the Perkox SDK.
class PerkoxInitConfig {
  /// The App ID registered in the Perkox Publisher Dashboard.
  final String appId;

  /// The SDK Key registered in the Perkox Publisher Dashboard.
  final String sdkKey;

  /// The unique player / user ID.
  final String? playerId;

  /// Whether to run the Offerwall in sandbox / beta testing mode.
  final bool beta;

  const PerkoxInitConfig({
    required this.appId,
    required this.sdkKey,
    this.playerId,
    this.beta = false,
  });

  Map<String, dynamic> toMap() => {
        'appId': appId,
        'sdkKey': sdkKey,
        'playerId': playerId,
        'beta': beta,
      };
}

/// Configuration object for an individual Offerwall instance.
class PerkoxOfferwallConfig extends PerkoxInitConfig {
  /// Callback fired when user earns a reward.
  final void Function(PerkoxReward reward)? onReward;

  /// Callback fired when the Offerwall is dismissed or closed.
  final void Function()? onClose;

  const PerkoxOfferwallConfig({
    required super.appId,
    required super.sdkKey,
    required String playerId,
    super.beta = false,
    this.onReward,
    this.onClose,
  }) : super(playerId: playerId);
}
