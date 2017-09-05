//
//  NITPermissionsManager.swift
//  Near-iOS-UI
//
//  Created by francesco.leoni on 04/09/17.
//  Copyright © 2017 Near. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

protocol NITPermissionsManagerDelegate {
    func permissionsManager(_ manager: NITPermissionsManager, didGrantLocationAuthorization granted: Bool)
    func permissionsManagerDidRequestNotificationPermissions(_ manager: NITPermissionsManager)
}

class NITPermissionsManager: NSObject {
    
    var delegate: NITPermissionsManagerDelegate?
    private let locationManager: CLLocationManager
    private let application: UIApplication
    
    private var _notificationCenter: AnyObject?
    @available(iOS 10.0, *)
    private var notificationCenter: UNUserNotificationCenter {
        get {
            return _notificationCenter as! UNUserNotificationCenter
        }
        set {
            _notificationCenter = notificationCenter
        }
    }
    
    override convenience init() {
        let locationManager = CLLocationManager()
        if #available(iOS 10.0, *) {
            self.init(locationManager: locationManager, notificationCenter: UNUserNotificationCenter.current(), application: UIApplication.shared)
        } else {
            // Fallback on earlier versions
            self.init(locationManager: locationManager, application: UIApplication.shared)
        }
    }
    
    @available(iOS 10.0, *)
    init(locationManager: CLLocationManager, notificationCenter: UNUserNotificationCenter, application: UIApplication) {
        self.locationManager = locationManager
        _notificationCenter = notificationCenter
        self.application = application
        super.init()
        self.locationManager.delegate = self
    }
    
    init(locationManager: CLLocationManager, application: UIApplication) {
        self.locationManager = locationManager
        self.application = application
        super.init()
        self.locationManager.delegate = self
    }
    
    func requestLocationPermission() {
        locationManager.requestAlwaysAuthorization()
    }
    
    func requestNotificationsPermission() {
        if #available(iOS 10.0, *) {
            notificationCenter.requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { (granted, error) in
                OperationQueue.main.addOperation({ 
                    self.delegate?.permissionsManagerDidRequestNotificationPermissions(self)
                })
            })
        } else {
            let settings = UIUserNotificationSettings(types: [.alert, .sound, .badge], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
            delegate?.permissionsManagerDidRequestNotificationPermissions(self)
        }
    }
}

extension NITPermissionsManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status != .notDetermined {
            delegate?.permissionsManager(self, didGrantLocationAuthorization: true)
        } else {
            delegate?.permissionsManager(self, didGrantLocationAuthorization: false)
        }
    }
    
}
