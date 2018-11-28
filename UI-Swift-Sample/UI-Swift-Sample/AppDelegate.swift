//
//  AppDelegate.swift
//  UI-Swift-Sample
//
//  Created by francesco.leoni on 30/08/17.
//  Copyright © 2017 Near. All rights reserved.
//

import UIKit
import NearITSDK
import OHHTTPStubs
import NearUIBinding
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        } else {
            // Fallback on earlier versions
        }
        NITLog.setLogEnabled(true)
        NITManager.setup(withApiKey: " - ")
        NITManager.default().start()
        
        enableStubForCoupons(true)
        enableStubForHistory(true)
        
        for family in UIFont.familyNames.sorted() {
            let names = UIFont.fontNames(forFamilyName: family)
            print("Family: \(family) Font names: \(names)")
        }
        
        NITUIAppearance.sharedInstance.regularFontName = "Raleway-Regular"
        NITUIAppearance.sharedInstance.mediumFontName = "Raleway-Medium"
        NITUIAppearance.sharedInstance.boldFontName = "Raleway-Bold"
        NITUIAppearance.sharedInstance.italicFontName = "Raleway-Italic"
        NITUIAppearance.sharedInstance.mediumItalicFontName = "Raleway-MediumItalic"
        NITUIAppearance.sharedInstance.boldItalicFontName = "Raleway-BoldItalic"
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        NITManager.default().stop()
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
        NITManager.default().start()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func enableStubForHistory(_ enabled: Bool) {
        stub(condition: { (request) -> Bool in
            if let urlString = request.url?.absoluteString {
                if urlString.contains("/notifications") {
                    return true
                }
            }
            return false
        }) { (request) -> OHHTTPStubsResponse in
            if let path = Bundle.main.path(forResource: "inbox_pushes", ofType: "json") {
                return OHHTTPStubsResponse(fileAtPath: path, statusCode: 200, headers: nil)
            } else {
                return OHHTTPStubsResponse()
            }
        }
    }
    
    func enableStubForCoupons(_ enabled: Bool) {
        stub(condition: { (request) -> Bool in
            if let urlString = request.url?.absoluteString {
                if urlString.contains("/coupons") {
                    return true
                }
            }
            return false
        }) { (request) -> OHHTTPStubsResponse in
            if let path = Bundle.main.path(forResource: "coupon", ofType: "json") {
                return OHHTTPStubsResponse(fileAtPath: path, statusCode: 200, headers: nil)
            } else {
                return OHHTTPStubsResponse()
            }
        }
    }
  
  func handleNearContent(content : NITReactionBundle , trackingInfo: NITTrackingInfo) {
    // handle near content
  }

}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
    
  @available(iOS 10.0, *)
  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo
    if let ui = userInfo as? [String : Any] {
      NITManager.default().processRecipe(userInfo: ui, completion: { (content, trackingInfo, error) in
        self.handleNearContent(content: content!, trackingInfo: trackingInfo!)
      })
    }
  }
}

