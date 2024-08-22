import UIKit
import Firebase
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  var flutterViewController: FlutterViewController?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    setupNotification(application)

    GeneratedPluginRegistrant.register(with: self)

    if let controller = window?.rootViewController as? FlutterViewController {
      flutterViewController = controller
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func setupNotification(_ application: UIApplication) {
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { _, _ in }
      Messaging.messaging().delegate = self
    } else {
      let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
      application.registerUserNotificationSettings(settings)
    }
    application.registerForRemoteNotifications()
  }

  @objc func getFcmToken(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if let fcmToken = Messaging.messaging().fcmToken {
      result(fcmToken)
    } else {
      result(nil)
    }
  }
}

extension AppDelegate: MessagingDelegate {
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    print("### Firebase fCMToken HERE ==>  \(fcmToken ?? "")")

    if let controller = flutterViewController {
      let channel = FlutterMethodChannel(name: "getfCMTokeniOS", binaryMessenger: controller.binaryMessenger)
      channel.invokeMethod("getFcmToken", arguments: fcmToken)
    }
  }
}
