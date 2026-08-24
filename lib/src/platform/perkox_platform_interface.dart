import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import '../models/perkox_reward.dart';
import 'perkox_method_channel.dart';

abstract class PerkoxPlatform extends PlatformInterface {
  PerkoxPlatform() : super(token: _token);

  static final Object _token = Object();

  static PerkoxPlatform _instance = MethodChannelPerkox();

  static PerkoxPlatform get instance => _instance;

  static set instance(PerkoxPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<bool> initSDK({
    required String appId,
    required String sdkKey,
    String? playerId,
    bool beta = false,
  }) {
    throw UnimplementedError('initSDK() has not been implemented.');
  }

  Future<bool> setUserId(String playerId) {
    throw UnimplementedError('setUserId() has not been implemented.');
  }

  Future<bool> showOfferwall({
    required String appId,
    required String sdkKey,
    required String playerId,
    bool beta = false,
  }) {
    throw UnimplementedError('showOfferwall() has not been implemented.');
  }

  Stream<PerkoxReward> get onRewardStream {
    throw UnimplementedError('onRewardStream has not been implemented.');
  }

  Stream<void> get onCloseStream {
    throw UnimplementedError('onCloseStream has not been implemented.');
  }
}
