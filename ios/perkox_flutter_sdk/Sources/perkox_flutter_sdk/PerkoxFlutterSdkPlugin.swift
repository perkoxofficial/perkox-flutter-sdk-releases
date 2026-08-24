import Flutter
import UIKit

#if canImport(PerkoxOfferwall)
import PerkoxOfferwall
#endif

public class PerkoxFlutterSdkPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {

    private var methodChannel: FlutterMethodChannel?
    private var eventChannel: FlutterEventChannel?
    private var eventSink: FlutterEventSink?

    private var activeAppId: String = ""
    private var activeSdkKey: String = ""
    private var activePlayerId: String = ""
    private var activeBeta: Bool = false

    public static func register(with registrar: FlutterPluginRegistrar) {
        let methodChannel = FlutterMethodChannel(
            name: "com.perkox.flutter_sdk/methods",
            binaryMessenger: registrar.messenger()
        )
        let eventChannel = FlutterEventChannel(
            name: "com.perkox.flutter_sdk/events",
            binaryMessenger: registrar.messenger()
        )

        let instance = PerkoxFlutterSdkPlugin()
        instance.methodChannel = methodChannel
        instance.eventChannel = eventChannel

        registrar.addMethodCallDelegate(instance, channel: methodChannel)
        eventChannel.setStreamHandler(instance)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initSDK":
            if let args = call.arguments as? [String: Any] {
                let appId = args["appId"] as? String ?? ""
                let sdkKey = args["sdkKey"] as? String ?? ""
                let playerId = args["playerId"] as? String ?? ""
                let beta = args["beta"] as? Bool ?? false

                activeAppId = appId != "undefined" ? appId : ""
                activeSdkKey = sdkKey != "undefined" ? sdkKey : ""
                activePlayerId = playerId != "undefined" ? playerId : ""
                activeBeta = beta
            }
            result(true)

        case "setUserId":
            if let args = call.arguments as? [String: Any] {
                let playerId = args["playerId"] as? String ?? ""
                activePlayerId = playerId != "undefined" ? playerId : ""
            }
            result(true)

        case "showOfferwall":
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }

                guard let topVC = self.getTopViewController() else {
                    result(FlutterError(code: "NO_VIEW_CONTROLLER", message: "Unable to find top view controller to present offerwall", details: nil))
                    return
                }

                let args = call.arguments as? [String: Any]
                let appIdArg = args?["appId"] as? String
                let sdkKeyArg = args?["sdkKey"] as? String
                let playerIdArg = args?["playerId"] as? String
                let betaArg = args?["beta"] as? Bool ?? self.activeBeta

                let app = (appIdArg != nil && !appIdArg!.isEmpty && appIdArg != "undefined") ? appIdArg! : self.activeAppId
                let key = (sdkKeyArg != nil && !sdkKeyArg!.isEmpty && sdkKeyArg != "undefined") ? sdkKeyArg! : self.activeSdkKey
                let user = (playerIdArg != nil && !playerIdArg!.isEmpty && playerIdArg != "undefined") ? playerIdArg! : self.activePlayerId

                if app.isEmpty || key.isEmpty {
                    result(FlutterError(code: "INVALID_CONFIG", message: "appId and sdkKey must be provided", details: nil))
                    return
                }

                #if canImport(PerkoxOfferwall)
                let offerwall = PerkoxOfferwall.create(
                    appId: app,
                    sdkKey: key,
                    playerId: user
                )

                offerwall.onReward = { [weak self] reward in
                    var rewardMap: [String: Any] = [:]
                    for (k, v) in reward {
                        if let val = v {
                            rewardMap[k] = val
                        }
                    }

                    DispatchQueue.main.async {
                        // Dispatch via MethodChannel
                        self?.methodChannel?.invokeMethod("onPerkoxReward", arguments: rewardMap)

                        // Dispatch via EventChannel
                        self?.eventSink?([
                            "event": "onPerkoxReward",
                            "data": rewardMap
                        ])
                    }
                }

                offerwall.onClose = { [weak self] in
                    DispatchQueue.main.async {
                        // Dispatch via MethodChannel
                        self?.methodChannel?.invokeMethod("onPerkoxClose", arguments: nil)

                        // Dispatch via EventChannel
                        self?.eventSink?([
                            "event": "onPerkoxClose"
                        ])
                    }
                }

                offerwall.launch(viewController: topVC, beta: betaArg)
                result(true)
                #else
                result(FlutterError(code: "PERKOX_IOS_SDK_MISSING", message: "PerkoxOfferwall.xcframework is not linked in podspec", details: nil))
                #endif
            }

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func getTopViewController(from rootVC: UIViewController? = nil) -> UIViewController? {
        let root = rootVC ?? {
            if #available(iOS 13.0, *) {
                return UIApplication.shared.connectedScenes
                    .compactMap { $0 as? UIWindowScene }
                    .flatMap { $0.windows }
                    .first(where: { $0.isKeyWindow })?.rootViewController
            } else {
                return UIApplication.shared.keyWindow?.rootViewController
            }
        }()

        if let nav = root as? UINavigationController {
            return getTopViewController(from: nav.visibleViewController)
        }
        if let tab = root as? UITabBarController {
            return getTopViewController(from: tab.selectedViewController)
        }
        if let presented = root?.presentedViewController {
            return getTopViewController(from: presented)
        }
        return root
    }

    // --- FlutterStreamHandler ---
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
}
