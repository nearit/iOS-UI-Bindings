//
//  NITPermissionsManager.swift
//  Near-iOS-UI
//
//  Created by francesco.leoni on 04/09/17.
//  Copyright © 2017 Near. All rights reserved.
//
// d

import UIKit
import CoreLocation
import UserNotifications

public protocol NITPermissionsManagerDelegate: class {
    func permissionsManager(_ manager: NITPermissionsManager,
                            didGrantLocationAuthorization granted: Bool,
                            withStatus status: CLAuthorizationStatus)
    func permissionsManagerDidRequestNotificationPermissions(_ manager: NITPermissionsManager)
}

public class NITPermissionsManager: NSObject {
    
    public weak var delegate: NITPermissionsManagerDelegate?
    private let locationManager: CLLocationManager
    private let application: UIApplication
    
    private var _notificationCenter: AnyObject?
    @available(iOS 10.0, *)
    private var notificationCenter: UNUserNotificationCenter {
        get {
            // swiftlint:disable force_cast
            return _notificationCenter as! UNUserNotificationCenter
        }
        set {
            _notificationCenter = newValue
        }
    }
    
    public override convenience init() {
        let locationManager = CLLocationManager()
        if #available(iOS 10.0, *) {
            self.init(locationManager: locationManager,
                      notificationCenter: UNUserNotificationCenter.current(),
                      application: UIApplication.shared)
        } else {
            // Fallback on earlier versions
            self.init(locationManager: locationManager, application: UIApplication.shared)
        }
    }
    
    @available(iOS 10.0, *)
    public init(locationManager: CLLocationManager,
                notificationCenter: UNUserNotificationCenter,
                application: UIApplication) {
        self.locationManager = locationManager
        _notificationCenter = notificationCenter
        self.application = application
        super.init()
        self.locationManager.delegate = self
    }
    
    public init(locationManager: CLLocationManager, application: UIApplication) {
        self.locationManager = locationManager
        self.application = application
        super.init()
        self.locationManager.delegate = self
    }
    
    public func requestLocationPermission(minStatus: CLAuthorizationStatus) {
        if isLocationNotDetermined() {
            locationManager.requestAlwaysAuthorization()
        } else if !isLocationGranted(status: minStatus) {
            self.openAppSettings()
        }
    }
    
    public func requestNotificationsPermission() {
        if #available(iOS 10.0, *) {
            notificationCenter.getNotificationSettings { (settings) in
                DispatchQueue.main.async {
                    if settings.authorizationStatus == .notDetermined {
                        self.notificationCenter.requestAuthorization(options: [.alert, .sound, .badge],
                                                                     completionHandler: { (_, _) in
                            OperationQueue.main.addOperation({
                                self.delegate?.permissionsManagerDidRequestNotificationPermissions(self)
                            })
                        })
                    } else if settings.authorizationStatus == .denied {
                        self.openAppSettings()
                    }
                }
            }
            
        } else {
            let settings = UIUserNotificationSettings(types: [.alert, .sound, .badge], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
            delegate?.permissionsManagerDidRequestNotificationPermissions(self)
        }
    }
    
    public func allPermissionsGranted(minLevel: CLAuthorizationStatus = .authorizedAlways,
                                      completionHandler: @escaping (Bool) -> Void) {
        isNotificationAvailable { (available) in
            if available {
                if self.isLocationGranted(status: minLevel) {
                    completionHandler(true)
                } else {
                    completionHandler(false)
                }
            } else {
                completionHandler(false)
            }
        }
    }
    
    public func isNotificationAvailable(_ completionHandler: @escaping (Bool) -> Void) {
        if #available(iOS 10.0, *) {
            notificationCenter.getNotificationSettings { (settings) in
                DispatchQueue.main.async {
                    if settings.authorizationStatus == .authorized {
                        completionHandler(true)
                    } else {
                        completionHandler(false)
                    }
                }
            }
        } else {
            if let settings = application.currentUserNotificationSettings {
                if settings.types.contains(.alert) ||
                    settings.types.contains(.badge) ||
                    settings.types.contains(.sound) {
                    completionHandler(true)
                } else {
                    completionHandler(false)
                }
            } else {
                completionHandler(false)
            }
        }
    }
    
    public func status(_ actualStatus: CLAuthorizationStatus, isAtLeast minStatus: CLAuthorizationStatus) -> Bool {
        if minStatus == .authorizedWhenInUse {
            return actualStatus == .authorizedWhenInUse || actualStatus == .authorizedAlways
        } else if minStatus == .authorizedAlways {
            return actualStatus == .authorizedAlways
        }
        return false
    }
    
    public func locationStatus() -> CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }
    
    public func isNotificationStatusDetermined(_ completionHandler:@escaping (Bool) -> Void) {
        if #available(iOS 10.0, *) {
            notificationCenter.getNotificationSettings { (settings) in
                DispatchQueue.main.async {
                    completionHandler(settings.authorizationStatus != .notDetermined)
                }
            }
        } else {
            completionHandler(true)
        }
    }
    
    public func isLocationGranted(status: CLAuthorizationStatus) -> Bool {
        let osStatus = CLLocationManager.authorizationStatus()
        if osStatus == status {
            return true
        }
        return false
    }
    
    public func isLocationGrantedAtLeast(minStatus: CLAuthorizationStatus) -> Bool {
        let currentStatus = CLLocationManager.authorizationStatus()
        return self.status(currentStatus, isAtLeast: minStatus)
    }

    public func isLocationPartiallyGranted() -> Bool {
        let authStatus = CLLocationManager.authorizationStatus()
        return (authStatus == .authorizedAlways || authStatus == .authorizedWhenInUse)
    }
    
    public func isLocationNotDetermined() -> Bool {
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .notDetermined {
            return true
        }
        return false
    }
    
    public func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
}

extension NITPermissionsManager: CLLocationManagerDelegate {
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .notDetermined {
            return
        }
        if isLocationGranted(status: .authorizedAlways) {
            delegate?.permissionsManager(self, didGrantLocationAuthorization: true, withStatus: status)
        } else {
            delegate?.permissionsManager(self, didGrantLocationAuthorization: false, withStatus: status)
        }
    }
    
}
