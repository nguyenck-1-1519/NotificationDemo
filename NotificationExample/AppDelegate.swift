//
//  AppDelegate.swift
//  NotificationExample
//
//  Created by can.khac.nguyen on 3/13/19.
//  Copyright © 2019 can.khac.nguyen. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications
import FirebaseMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        configNotification(application)
        configLocalNotification()
        removeLocalNotification()
//        scheduleLocalNotification()
        Messaging.messaging().delegate = self

        // handle action tap on notification while app closed
        if let _ = launchOptions?[.remoteNotification] {
            //
        }
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print(token)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // handle when get fail DeviceToken
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instance ID: \(error)")
            } else if let result = result {
                print("remote instance ID token: \(result.token)")
            }
        }
    }

    // MARK: Handle tap on notification
    // For IOS 10, *
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        // handle action while tap in appstate = inactive
    }

    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        // handle action while tap in appstate = inactive
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }

    private func configNotification(_ application: UIApplication) {
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
    }

    private func configLocalNotification() {
        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound, .sound]
        center.requestAuthorization(options: options) { (granted, error) in
            if let error = error {
                // handle error while request authorization
                print("Error while request authorization \(error)")
            } else {
                if granted {
                    print("Request notification success")
                } else {
                    print("Request notification fail")
                }
            }
        }
    }

    private func scheduleLocalNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Daily remind"
        content.body = "Strong body, Strong mind"
        content.sound = UNNotificationSound.default()

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 100, repeats: true)
        let identifier = "local notification"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("There is something wrong, hmm")
            }
        }
    }

    private func removeLocalNotification() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()    }
}

