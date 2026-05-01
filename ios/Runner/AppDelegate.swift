import Flutter
import FirebaseMessaging
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate,
    MessagingDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Set delegates before super so no notification events are missed.
    UNUserNotificationCenter.current().delegate = self
    Messaging.messaging().delegate = self

    // Request APNs token early; firebase_messaging Flutter plugin forwards
    // it to FCM. On the iOS simulator there is no aps-environment
    // entitlement, so calling this raises an uncaught NSCocoaError —
    // we skip on the simulator and let real builds register.
    #if !targetEnvironment(simulator)
    application.registerForRemoteNotifications()
    #endif

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  // Show banner + badge + sound when the app is in the foreground.
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    completionHandler([.banner, .badge, .sound])
  }

  // Let FlutterAppDelegate handle the tap so firebase_messaging can forward it to Dart.
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    super.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
  }

  // FCM token refresh is forwarded to Dart automatically by the firebase_messaging plugin.
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {}
}
