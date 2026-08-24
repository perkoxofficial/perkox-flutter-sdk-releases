/// Optional runtime overrides when displaying the Perkox Offerwall.
class PerkoxOfferwallOptions {
  final String? appId;
  final String? sdkKey;
  final String? playerId;
  final bool? beta;

  const PerkoxOfferwallOptions({
    this.appId,
    this.sdkKey,
    this.playerId,
    this.beta,
  });

  Map<String, dynamic> toMap() => {
        if (appId != null) 'appId': appId,
        if (sdkKey != null) 'sdkKey': sdkKey,
        if (playerId != null) 'playerId': playerId,
        if (beta != null) 'beta': beta,
      };
}
