package com.perkox.perkox_flutter_sdk

import android.app.Activity
import android.os.Handler
import android.os.Looper
import com.perkoxofferwall.sdk.Offerwall
import com.perkoxofferwall.sdk.PerkoxOfferwall
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/**
 * PerkoxFlutterSdkPlugin
 * Bridges Flutter calls to native Perkox Android SDK.
 */
class PerkoxFlutterSdkPlugin :
    FlutterPlugin,
    MethodCallHandler,
    ActivityAware,
    EventChannel.StreamHandler {

    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var eventSink: EventChannel.EventSink? = null
    private var currentActivity: Activity? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    private var activeAppId: String = ""
    private var activeSdkKey: String = ""
    private var activePlayerId: String = ""
    private var activeBeta: Boolean = false

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, METHOD_CHANNEL_NAME)
        methodChannel.setMethodCallHandler(this)

        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, EVENT_CHANNEL_NAME)
        eventChannel.setStreamHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "initSDK" -> {
                val appId = call.argument<String>("appId") ?: ""
                val sdkKey = call.argument<String>("sdkKey") ?: ""
                val playerId = call.argument<String>("playerId") ?: ""
                val beta = call.argument<Boolean>("beta") ?: false

                activeAppId = if (appId != "undefined") appId else ""
                activeSdkKey = if (sdkKey != "undefined") sdkKey else ""
                activePlayerId = if (playerId != "undefined") playerId else ""
                activeBeta = beta

                result.success(true)
            }

            "setUserId" -> {
                val playerId = call.argument<String>("playerId") ?: ""
                activePlayerId = if (playerId != "undefined") playerId else ""
                result.success(true)
            }

            "showOfferwall" -> {
                val activity = currentActivity
                if (activity == null) {
                    result.error("NO_ACTIVITY", "Cannot show offerwall without an active foreground Activity", null)
                    return
                }

                try {
                    val appIdArg = call.argument<String>("appId")
                    val sdkKeyArg = call.argument<String>("sdkKey")
                    val playerIdArg = call.argument<String>("playerId")
                    val betaArg = call.argument<Boolean>("beta") ?: activeBeta

                    val app = if (!appIdArg.isNullOrEmpty() && appIdArg != "undefined") appIdArg else activeAppId
                    val key = if (!sdkKeyArg.isNullOrEmpty() && sdkKeyArg != "undefined") sdkKeyArg else activeSdkKey
                    val user = if (!playerIdArg.isNullOrEmpty() && playerIdArg != "undefined") playerIdArg else activePlayerId

                    if (app.isEmpty() || key.isEmpty()) {
                        result.error("INVALID_CONFIG", "appId and sdkKey must be provided", null)
                        return
                    }

                    val offerwall: Offerwall = PerkoxOfferwall.create(app, key, user)

                    offerwall.onReward = { rewardMap ->
                        mainHandler.post {
                            val data = rewardMap ?: emptyMap<String, Any?>()
                            // Dispatch via MethodChannel invokeMethod
                            methodChannel.invokeMethod("onPerkoxReward", data)

                            // Also dispatch via EventChannel
                            eventSink?.success(
                                mapOf(
                                    "event" to "onPerkoxReward",
                                    "data" to data
                                )
                            )
                        }
                    }

                    offerwall.onClose = {
                        mainHandler.post {
                            // Dispatch via MethodChannel invokeMethod
                            methodChannel.invokeMethod("onPerkoxClose", null)

                            // Also dispatch via EventChannel
                            eventSink?.success(
                                mapOf(
                                    "event" to "onPerkoxClose"
                                )
                            )
                        }
                    }

                    offerwall.launch(activity, betaArg)
                    result.success(true)
                } catch (e: Exception) {
                    result.error("PERKOX_LAUNCH_ERROR", e.message, e.stackTraceToString())
                }
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }

    // --- ActivityAware Lifecycle ---
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        currentActivity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        currentActivity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        currentActivity = binding.activity
    }

    override fun onDetachedFromActivity() {
        currentActivity = null
    }

    // --- StreamHandler for EventChannel ---
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    companion object {
        const val METHOD_CHANNEL_NAME = "com.perkox.flutter_sdk/methods"
        const val EVENT_CHANNEL_NAME = "com.perkox.flutter_sdk/events"
    }
}
