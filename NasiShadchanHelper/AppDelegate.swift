//
//  AppDelegate.swift
//  NasiShadchanHelper
//
//  Created by user on 4/24/20.
//  Copyright © 2020 user. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging
import FirebaseAnalytics
import IQKeyboardManagerSwift


enum Identifiers {
  static let viewAction = "VIEW_IDENTIFIER"
  static let newsCategory = "NEWS_CATEGORY"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    class func instance() -> AppDelegate { return UIApplication.shared.delegate as! AppDelegate }
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        application.applicationIconBadgeNumber = 5
        
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        Database.database().isPersistenceEnabled = true
        //Firebase.Analytics.setAnalyticsCollectionEnabled(true)

        // -- IQKeyboardManager---
        IQKeyboardManager.shared.enable = true
        
        
        if UserInfo.currentUserExists {
             self.makingRootFlow(Constant.AppRootFlow.kEnterApp)
        } else {
             self.makingRootFlow(Constant.AppRootFlow.kAuthVc)
        }
        //setUpNavigationAppearance()
        
        
        // 1 set appDelegate to get call backs from UserNotificationCenter
        UNUserNotificationCenter.current().delegate = self
        
        
        // 2 what authoriations do we need for the notifications
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        
        // get the current and center and request authorization from user
        // pass in the auth options
        UNUserNotificationCenter.current().requestAuthorization(
          options: authOptions) { _, _ in }
        
        // check if user authorized notifications and if yes
        // register for remote notifications
        getNotificationSettings()
        
        
        // firebase is going to broadcast the message so we
        // need the firebase callback and handle the
        // tokens
        Messaging.messaging().delegate = self
        
        
        // if the apps was in the background the system invokes
        // the didLaunchWith Options
        // Check if launched from notification
        // if yes it will contain the payload
        let notificationOption = launchOptions?[.remoteNotification]

        // 1
        if
          let notification = notificationOption as? [String: AnyObject],
          let aps = notification["aps"] as? [String: AnyObject] {
          // 2
          //NewsItem.makeNewsItem(aps)
          
          // 3
         // (window?.rootViewController as? UITabBarController)?.selectedIndex = 1
        }

        

        return true
    }
    
    // if app was running when notification was tapped then this method gets
    // invoked
    func application(
      _ application: UIApplication,
      didReceiveRemoteNotification userInfo: [AnyHashable: Any],
      fetchCompletionHandler completionHandler:
      @escaping (UIBackgroundFetchResult) -> Void
    ) {
      guard let aps = userInfo["aps"] as? [String: AnyObject] else {
        completionHandler(.failed)
        return
      }
      //NewsItem.makeNewsItem(aps)
    }

    
    
    func registerForPushNotifications() {
      UNUserNotificationCenter.current()
        
        .requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
          print("Permission granted: \(granted)")
          
          guard granted else { return }
            
            // 1
            let viewAction = UNNotificationAction(
              identifier: Identifiers.viewAction,
              title: "View",
              options: [.foreground])

            // 2
            let newsCategory = UNNotificationCategory(
              identifier: Identifiers.newsCategory,
              actions: [viewAction],
              intentIdentifiers: [],
              options: [])

            // 3
            UNUserNotificationCenter.current().setNotificationCategories([newsCategory])

          
         
          
          // after calling registerForNotifcations
          // call method that checks the auth status
          self?.getNotificationSettings()
        }
    }

    func getNotificationSettings() {
      UNUserNotificationCenter.current().getNotificationSettings { settings in
        print("Notification settings: \(settings)")
        guard settings.authorizationStatus == .authorized else { return }
        
        
        // 3 tell application object to register with apple APNs
        // for remote notifications if registration succeeds
        // the delegate method "didRegister" is invoked passing in
        // the device token
        // device token gets sent to Firebase
        // the token is provided by APNs and uniquely identifies this app on this particular device.
        //application.registerForRemoteNotifications()
        DispatchQueue.main.async {
          UIApplication.shared.registerForRemoteNotifications()
        }
      }
    }
    
    
    
    // MARK:- MEthods
    private func setUpNavigationAppearance() {
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().barTintColor = .yellow
        UINavigationBar.appearance().backgroundColor = .green
        UIBarButtonItem.appearance() .tintColor = UIColor.red
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18), NSAttributedString.Key.foregroundColor: UIColor.white]
        UIBarButtonItem.appearance().setTitleTextAttributes(
            [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 18), NSAttributedString.Key.foregroundColor: UIColor.white],
            for: .normal)
    }
    
    // MARK: - Making RootView Controller
    func makingRootFlow(_ strRoot: String) {
        
        self.window?.rootViewController?.removeFromParent()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if strRoot == Constant.AppRootFlow.kEnterApp {
            let tabBar = storyboard.instantiateViewController(withIdentifier: "MyTabBarController")
            
            window?.rootViewController = tabBar
            
        } else if strRoot == Constant.AppRootFlow.kAuthVc {
            
            let authStoryboard = UIStoryboard(name: "UserAuthentication", bundle: nil)
            
            let vcNav : AuthNavViewController = authStoryboard.instantiateViewController()
            
            window?.rootViewController = vcNav
        }
    }
    
   
        
}

extension AppDelegate: UNUserNotificationCenterDelegate {
  
    
    private func process(_ notification: UNNotification) {
      // 1
      let userInfo = notification.request.content.userInfo
        
      print("the user info content is \(userInfo.description)")
      
      // 2
      //UIApplication.shared.applicationIconBadgeNumber = 3
        
     // if let newsTitle = userInfo["newsTitle"] as? String,
        //let newsBody = userInfo["newsBody"] as? String {
        //let newsItem = NewsItem(title: newsTitle, body: newsBody, date: Date())
        //NewsModel.shared.add([newsItem])
      }
    

    
    // when u receive a notification while app is in foreground
    // this gets invoked
    func userNotificationCenter(
      _ center: UNUserNotificationCenter,
      willPresent notification: UNNotification,
      withCompletionHandler completionHandler:
      @escaping (UNNotificationPresentationOptions) -> Void
    ) {
      process(notification)
        if #available(iOS 14.0, *) {
            completionHandler([[.banner, .sound]])
        } else {
            // Fallback on earlier versions
        }
    }

    //  if a notification is received while app is in background
    // this method is invoked
    // so we call the helper method "process" before the completionHandler
    func userNotificationCenter(
      _ center: UNUserNotificationCenter,
      didReceive response: UNNotificationResponse,
      withCompletionHandler completionHandler: @escaping () -> Void
    ) {
      process(response.notification)
      completionHandler()
    }

  // if registration with apple service is succesful
  // this delegate method gets called and the device token is
  // passed in
  // the token is an identifier that points to the unique device
  // it needs to get sent to firebase who will send it apple's APNs
  // apple then uses the tokens to know which devices to send the notification to and for which app on that device
  func application(_ application: UIApplication,
      didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
  
    // convert token from data object to string
    let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
      let token = tokenParts.joined()
      print("Device Token: \(token)")
        
      Messaging.messaging().apnsToken = deviceToken
      }
    
    
    func application(
      _ application: UIApplication,
      didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
      print("Failed to register: \(error)")
    }

}

extension AppDelegate: MessagingDelegate {
    
  func messaging(
    _ messaging: Messaging,
    didReceiveRegistrationToken fcmToken: String
  ) {
    
    let tokenDict = ["token": fcmToken ]
    
    NotificationCenter.default.post(
      name: Notification.Name("FCMToken"),
      object: nil,
      userInfo: tokenDict)
  }
    
}
    
    




































