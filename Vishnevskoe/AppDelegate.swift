//
//  AppDelegate.swift
//  Vishnevskoe
//
//  Created by Chingiz Bayshurin on 10.06.16.
//  Copyright © 2016 Chingiz Bayshurin. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics




@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate  {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        //we start Fabric library for application sharing using fabric.io service
        Fabric.sharedSDK().debug = false
        //Fabric.with([Crashlytics.self])
        
        //we invoke push notification register procedure
        registerForPushNotifications(application)
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
    }

    func applicationDidEnterBackground(application: UIApplication) {
    }

    func applicationWillEnterForeground(application: UIApplication) {
    }

    func applicationDidBecomeActive(application: UIApplication) {
    }

    func applicationWillTerminate(application: UIApplication) {
    }

     //------------  PUSH NOTIFICATION REGISTARTION PROCEDURE (iOS7, iOS 8 and above-------------------
    //Request for adding permissions for push notifications
    func registerForPushNotifications(application: UIApplication) {
        if #available(iOS 8.0, *) {
            let notificationSettings = UIUserNotificationSettings(
                forTypes: [.Badge, .Sound, .Alert], categories: nil)
            application.registerUserNotificationSettings(notificationSettings)
        } else {
            // Fallback for iOS 7
            let notificationTypes = UIRemoteNotificationType (arrayLiteral: .Badge, .Sound, .Alert)
            application.registerForRemoteNotificationTypes(notificationTypes)
        }
    }
    
    
    //we find out what choice user has made
    @available(iOS 8.0, *)
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != .None {
            application.registerForRemoteNotifications()
        }
    }
    

    //yeah, this is device token if registration on APNS server was successfull
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = ""
        
        for i in 0..<deviceToken.length {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        print("AppDelegate:   I've got Device Token - ", tokenString)
    
        //We are saving our deviceToken and then send it to our server
        Cabinet.deviceToken = tokenString
        NetworkManager.savePushToken()
       // NetworkManager.savePushTokenTest()
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Failed to register:", error)
    }
    //--------------------------------------------------------------------------------------------
}


