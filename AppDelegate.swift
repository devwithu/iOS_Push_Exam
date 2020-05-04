//
//  AppDelegate.swift
//  UserNotification
//
//  Created by Zedd on 2017. 8. 6..
//  Copyright © 2017년 Zedd. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
          
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          
//        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { _, _ in }
//        application.registerForRemoteNotifications()
        
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("D'oh: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                                   application.registerForRemoteNotifications()
                               }
                //application.registerForRemoteNotifications()
            }
        }
        
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
      let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
      print("[Log] deviceToken :", deviceTokenString)
        
      Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for notifications: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
      if let aps = userInfo["aps"] as? [String: Any],
        let alert = aps["alert"] as? [String: String],
        let body = alert["body"],
        let title = alert["title"]
      {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
            
        print("title")
        print(title)
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        let request = UNNotificationRequest(identifier: "FCM Contents", content: content, trigger: trigger)
            
        UNUserNotificationCenter.current().add(request) { (error) in
          if let error = error {
            print(error.localizedDescription)
          }
        }
      }

      completionHandler(UIBackgroundFetchResult.newData)
    }
}

extension AppDelegate: MessagingDelegate {
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
    
    print("Firebase registration token: \(fcmToken)")
    
    let dataDict: [String: String] = ["token": fcmToken]
    
    NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
  }
  
  func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
    print("[Log] didReceive :", messaging)
  }
}
extension AppDelegate: UNUserNotificationCenterDelegate {
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler([.alert, .badge, .sound])
  }
  
  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    completionHandler()
  }
}
