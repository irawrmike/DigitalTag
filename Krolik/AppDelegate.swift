//
//  AppDelegate.swift
//  Krolik
//
//  Created by Colin Russell, Mike Cameron, and Mike Stoltman
//  Copyright © 2018 Krolik Team. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications
import FirebaseMessaging
import FirebaseDatabase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    var window: UIWindow?
    let userDefaults = UserDefaults.standard
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        registerNotifications(application)
        application.registerForRemoteNotifications()
        return true
    }
    
    func registerNotifications(_ application: UIApplication) {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (success, error) in
            print(#line, success, error ?? "No error")
        }
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Message was received")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .sound, .badge])
    }
    
    
    //FIREBASE CLOUD MESSAGING
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        //CHECK TOKEN RECEIVED FROM FCM
        guard let token = Messaging.messaging().fcmToken else { return }
        print(#line, "FCM token: \(token)")
        //STORE TOKEN IN USER DEFAULTS
        userDefaults.set(token, forKey: "FCMToken")
        //STORE TOKEN IN DATABASE CURRENT PATH "DEVICES" NEEDS FIXING
        let ref = Database.database().reference().child("devices")
        ref.updateChildValues([token : true])
    }
    
}

