import UIKit
import Flutter
import Firebase
import awesome_notifications
import shared_preferences_ios

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, MessagingDelegate  {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    Messaging.messaging().delegate = self
    GeneratedPluginRegistrant.register(with: self)

    // This function register the desired plugins to be used within a notification background action
    SwiftAwesomeNotificationsPlugin.setPluginRegistrantCallback { registry in
      SwiftAwesomeNotificationsPlugin.register(
        with: registry.registrar(forPlugin: "io.flutter.plugins.awesomenotifications.AwesomeNotificationsPlugin")!)
      FLTSharedPreferencesPlugin.register(
        with: registry.registrar(forPlugin: "io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin")!)
    }

    // This function register the desired plugins to be used within silent push notifications
    SwiftAwesomeNotificationsFcmPlugin.setPluginRegistrantCallback { registry in
      SwiftAwesomeNotificationsPlugin.register(
        with: registry.registrar(forPlugin: "io.flutter.plugins.awesomenotifications.AwesomeNotificationsPlugin")!)
      FLTSharedPreferencesPlugin.register(
        with: registry.registrar(forPlugin: "io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin")!)
    }

    if #available(iOS 10.0, *) {
        // For iOS 10 display notification (sent via APNS)
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
    } else {
        let settings: UIUserNotificationSettings =
        UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        application.registerUserNotificationSettings(settings)
    }
    application.registerForRemoteNotifications()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}