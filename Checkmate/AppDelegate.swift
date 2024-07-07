//
//  AppDelegate.swift
//  Checkmate
//
//  Created by Mag isb-10 on 04/07/2024.
//

import UIKit
import IQKeyboardManager

@main

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let controller = storyboard.instantiateViewController(withIdentifier: String(describing: "TabbarVC")) as? TabbarVC
    let navigation = UINavigationController(rootViewController: controller!)
    self.window?.rootViewController = navigation
    
    
    if #available(iOS 15, *) {
      let navigationBarAppearance = UINavigationBarAppearance()
      navigationBarAppearance.configureWithOpaqueBackground()
      navigationBarAppearance.titleTextAttributes = [
        NSAttributedString.Key.foregroundColor : UIColor.white
      ]
      navigationBarAppearance.largeTitleTextAttributes = [
        NSAttributedString.Key.foregroundColor : UIColor.white
      ]
      navigationBarAppearance.backgroundColor = UIColor.PRIMARYBLACK
      UINavigationBar.appearance().standardAppearance = navigationBarAppearance
      UINavigationBar.appearance().compactAppearance = navigationBarAppearance
      UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
      
      // MARK: Tab bar appearance
      let tabBarAppearance = UITabBarAppearance()
      tabBarAppearance.configureWithOpaqueBackground()
      tabBarAppearance.backgroundColor = UIColor.PRIMARYBLACK
      UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
      UITabBar.appearance().standardAppearance = tabBarAppearance
    }
    
    IQKeyboardManager.shared().isEnabled = true
    IQKeyboardManager.shared().shouldResignOnTouchOutside = true
    IQKeyboardManager.shared().isEnableAutoToolbar = false
    
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
      if granted {
        print("Notification persmission granted")
      } else {
        print("Notification permission denied")
      }
    }
    UNUserNotificationCenter.current().delegate = self
    
    return true
  }
  
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler([.alert, .sound])
  }
}




