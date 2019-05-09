//
//  AppDelegate.swift
//  UI-Swift-Sample
//
//  Created by francesco.leoni on 30/08/17.
//  Copyright © 2017 Near. All rights reserved.
//

import UIKit
import NearITSDKSwift
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

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        NITManager.default().start()
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
        NearManager.shared.userNotificationCenter(center, willPresent: notification, withCompletionHandler: completionHandler)
    }
    
  @available(iOS 10.0, *)
  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        NearManager.shared.showContentFrom(response) { (content, trackingInfo, error) in
            if error != nil {
                // there was an error
            }
            if customJson = content as? NITCustomJSON {
                // handle the custom JSON
            }
        }
        completionHandler()
    }
  }
}

