import 'dart:async';
import 'package:flutter/services.dart';
import '../models/perkox_reward.dart';
import 'perkox_platform_interface.dart';

/// An implementation of [PerkoxPlatform] that uses method channels and event channels.
class MethodChannelPerkox extends PerkoxPlatform {
  final MethodChannel _methodChannel =
      const MethodChannel('com.perkox.flutter_sdk/methods');

  final EventChannel _eventChannel =
      const EventChannel('com.perkox.flutter_sdk/events');

  Stream<dynamic>? _rawEventStream;
  StreamController<PerkoxReward>? _rewardStreamController;
  StreamController<void>? _closeStreamController;

  MethodChannelPerkox() {
    _methodChannel.setMethodCallHandler(_handleMethodCall);
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onPerkoxReward':
        if (call.arguments is Map) {
          final reward =
              PerkoxReward.fromMap(call.arguments as Map<dynamic, dynamic>);
          _rewardStreamController?.add(reward);
        }
        break;
      case 'onPerkoxClose':
        _closeStreamController?.add(null);
        break;
      default:
        break;
    }
  }

  Stream<dynamic> _getEventStream() {
    _rawEventStream ??= _eventChannel.receiveBroadcastStream();
    return _rawEventStream!;
  }

  @override
  Future<bool> initSDK({
    required String appId,
    required String sdkKey,
    String? playerId,
    bool beta = false,
  }) async {
    try {
      final result = await _methodChannel.invokeMethod<bool>('initSDK', {
        'appId': appId,
        'sdkKey': sdkKey,
        'playerId': playerId ?? '',
        'beta': beta,
      });
      return result ?? true;
    } on PlatformException catch (e) {
      // ignore: avoid_print
      print('[Perkox SDK] Platform error during initSDK: ${e.message}');
      return false;
    } catch (e) {
      // ignore: avoid_print
      print('[Perkox SDK] Error during initSDK: $e');
      return false;
    }
  }

  @override
  Future<bool> setUserId(String playerId) async {
    try {
      final result = await _methodChannel.invokeMethod<bool>('setUserId', {
        'playerId': playerId,
      });
      return result ?? true;
    } on PlatformException catch (e) {
      // ignore: avoid_print
      print('[Perkox SDK] Platform error during setUserId: ${e.message}');
      return false;
    } catch (e) {
      // ignore: avoid_print
      print('[Perkox SDK] Error during setUserId: $e');
      return false;
    }
  }

  @override
  Future<bool> showOfferwall({
    required String appId,
    required String sdkKey,
    required String playerId,
    bool beta = false,
  }) async {
    try {
      final result = await _methodChannel.invokeMethod<bool>('showOfferwall', {
        'appId': appId,
        'sdkKey': sdkKey,
        'playerId': playerId,
        'beta': beta,
      });
      return result ?? true;
    } on PlatformException catch (e) {
      // ignore: avoid_print
      print('[Perkox SDK] Platform error during showOfferwall: ${e.message}');
      return false;
    } catch (e) {
      // ignore: avoid_print
      print('[Perkox SDK] Error during showOfferwall: $e');
      return false;
    }
  }

  @override
  Stream<PerkoxReward> get onRewardStream {
    if (_rewardStreamController == null) {
      _rewardStreamController = StreamController<PerkoxReward>.broadcast();

      // Listen to native EventChannel broadcast if active
      _getEventStream().listen((event) {
        if (event is Map) {
          final eventType = event['event']?.toString();
          if (eventType == 'onPerkoxReward' || event.containsKey('amount') || event.containsKey('txid')) {
            final data = event['data'] is Map ? event['data'] as Map : event;
            _rewardStreamController?.add(PerkoxReward.fromMap(data));
          }
        }
      }, onError: (err) {
        // ignore: avoid_print
        print('[Perkox SDK] EventChannel reward error: $err');
      });
    }
    return _rewardStreamController!.stream;
  }

  @override
  Stream<void> get onCloseStream {
    if (_closeStreamController == null) {
      _closeStreamController = StreamController<void>.broadcast();

      _getEventStream().listen((event) {
        if (event is Map) {
          final eventType = event['event']?.toString();
          if (eventType == 'onPerkoxClose') {
            _closeStreamController?.add(null);
          }
        }
      }, onError: (err) {
        // ignore: avoid_print
        print('[Perkox SDK] EventChannel close error: $err');
      });
    }
    return _closeStreamController!.stream;
  }
}
