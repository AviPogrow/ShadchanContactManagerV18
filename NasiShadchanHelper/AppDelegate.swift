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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    
    
    class func instance() -> AppDelegate { return UIApplication.shared.delegate as! AppDelegate }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
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
        return true
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






































