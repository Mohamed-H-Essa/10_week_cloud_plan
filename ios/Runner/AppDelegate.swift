import Flutter
import UIKit
import WidgetKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    let controller = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(
      name: "com.cloudstudy/widgets",
      binaryMessenger: controller.binaryMessenger
    )

    channel.setMethodCallHandler { (call, result) in
      if call.method == "updateWidgets" {
        guard let args = call.arguments as? [String: Any],
              let appGroup = args["appGroup"] as? String,
              let data = args["data"] as? String else {
          result(FlutterError(code: "BAD_ARGS", message: nil, details: nil))
          return
        }

        let defaults = UserDefaults(suiteName: appGroup)
        defaults?.set(data, forKey: "widgetData")
        defaults?.synchronize()

        if #available(iOS 14.0, *) {
          WidgetCenter.shared.reloadAllTimelines()
        }

        result(nil)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
