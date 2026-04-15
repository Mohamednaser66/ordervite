import Flutter
import UIKit
import AppTrackingTransparency
import AdSupport

@main
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    GeneratedPluginRegistrant.register(with: self)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func applicationDidBecomeActive(_ application: UIApplication) {
    super.applicationDidBecomeActive(application)

    if #available(iOS 14, *) {
      if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          ATTrackingManager.requestTrackingAuthorization { status in
            // optional: handle status
          }
        }
      }
    }
  }
}