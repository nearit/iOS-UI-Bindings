//
//  NITPermissionsViewController.swift
//  Near-iOS-UI
//
//  Created by francesco.leoni on 30/08/17.
//  Copyright © 2017 Near. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications
import NearITSDK

@objc public enum NITPermissionsType: NSInteger {
    case locationOnly = 0
    case notificationsOnly
    case locationAndNotifications
}

@objc public enum NITPermissionsLocationType: NSInteger {
    case always = 0
    case whenInUse = 1

    var authorizationStatus: CLAuthorizationStatus {
        get {
            switch self {
            case .always:
                return .authorizedAlways
            case .whenInUse:
                return .authorizedWhenInUse
            }
        }
    }
}

@objc public enum NITPermissionsAutoStartRadarType: NSInteger {
    case off = 0
    case on = 1
}

@objc public enum NITPermissionsAutoCloseDialog: NSInteger {
    case off = 0
    case on = 1
}

@objc public protocol NITPermissionsViewControllerDelegate: class {
    @objc optional func locationGranted(_ granted: Bool)
    @objc optional func notificationsGranted(_ granted: Bool)
    @objc optional func dialogClosed(locationGranted: Bool, notificationsGranted: Bool)
}

public class NITPermissionsViewController: NITBaseViewController {

    let permissionsManager = NITPermissionsManager()

    @IBOutlet weak var explain: UILabel!
    @IBOutlet weak var location: UIButton!
    @IBOutlet weak var notification: UIButton!
    @IBOutlet weak var footer: UIButton!
    @IBOutlet weak var header: UIImageView!
    @IBOutlet weak var locationContainer: UIView!
    @IBOutlet weak var notificationsContainer: UIView!

    @objc public var type: NITPermissionsType
    @objc public var locationType: NITPermissionsLocationType
    @objc public var autoStartRadar: NITPermissionsAutoStartRadarType
    @objc public var autoCloseDialog: NITPermissionsAutoCloseDialog

    @objc public var unknownButton: UIImage!
    @objc public var grantedButton: UIImage!
    @objc public var grantedIcon: UIImage!
    @objc public var headerImage: UIImage!
    @objc public var textColor: UIColor!
    @objc public var notificationsIcon: UIImage!
    @objc public var locationIcon: UIImage!

    @objc public var locationText: String!
    @objc public var notificationsText: String!
    @objc public var explainText: String!
    @objc public var closeText: String!
    @objc public var notNowText: String!

    @objc public var refreshOnAppActivation: Bool = true
    @objc public weak var delegate: NITPermissionsViewControllerDelegate?

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationDidBecomeActive(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if autoStartRadar == .on && checkPermissions() {
            let manager = NITManager.default()
            manager.start()
        }
        callClosingDelegate()
        NotificationCenter.default.removeObserver(self)
    }

    @objc public func checkPermissions() -> Bool {
        switch type {
        case .notificationsOnly:
            return permissionsManager.isNotificationAvailable()
        case .locationOnly:
            return permissionsManager.isLocationGrantedAtLeast(minStatus: locationType.authorizationStatus)
        case .locationAndNotifications:
            return permissionsManager.isNotificationAvailable() &&
                permissionsManager.isLocationGrantedAtLeast(minStatus: locationType.authorizationStatus)
        }
    }
    
    @objc func applicationDidBecomeActive(_ notification: Notification) {
        if refreshOnAppActivation {
            refreshButtons()
            eventuallyClose()
        }
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc public convenience init() {
        self.init(type: .locationAndNotifications, locationType: .always)
    }
    
    @objc public convenience init(locationType: NITPermissionsLocationType) {
        self.init(type: .locationAndNotifications, locationType: locationType)
    }
    
    @objc public convenience init(type: NITPermissionsType) {
        self.init(type: type, locationType: .always)
    }
    
    @objc public init(type: NITPermissionsType = .locationAndNotifications,
                      locationType: NITPermissionsLocationType = .always,
                      autoStartRadar: NITPermissionsAutoStartRadarType = .on,
                      autoCloseDialog: NITPermissionsAutoCloseDialog = .off) {
        self.type = type
        self.locationType = locationType
        self.autoStartRadar = autoStartRadar
        self.autoCloseDialog = autoCloseDialog
        
        let bundle = Bundle.NITBundle(for: NITDialogController.self)
        super.init(nibName: "NITPermissionsViewController", bundle: bundle)

        setupDefaultElements()
        permissionsManager.delegate = self
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupDefaultElements() {
        let bundle = Bundle.NITBundle(for: NITDialogController.self)

        let emptyOutline = UIImage(named: "outlinedButton", in: bundle, compatibleWith: nil)
        unknownButton = emptyOutline?.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 45, bottom: 0, right: 45))
        let filledOutline = UIImage(named: "filledButton", in: bundle, compatibleWith: nil)
        grantedButton = filledOutline?.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 45, bottom: 0, right: 45))
        grantedIcon = UIImage(named: "tick", in: bundle, compatibleWith: nil)
        headerImage = UIImage(named: "permissionsBanner", in: bundle, compatibleWith: nil)
        notificationsIcon = UIImage(named: "notifications", in: bundle, compatibleWith: nil)
        locationIcon = UIImage(named: "location", in: bundle, compatibleWith: nil)
        textColor = UIColor.nearWarmGrey

        locationText = NSLocalizedString("Permissions popup: LOCATION", tableName: nil, bundle: bundle, value: "LOCATION", comment: "Permissions popup: LOCATION")
        notificationsText = NSLocalizedString("Permissions popup: NOTIFICATIONS", tableName: nil, bundle: bundle, value: "NOTIFICATIONS", comment: "Permissions popup: NOTIFICATIONS")
        explainText = NSLocalizedString("Permissions popup: explanation", tableName: nil, bundle: bundle, value: "Permissions explanation", comment: "Permissions popup: explanation")
        closeText = NSLocalizedString("Permissions popup: Close", tableName: nil, bundle: bundle, value: "Close", comment: "Permissions popup: Close")
        notNowText = NSLocalizedString("Permissios popup: Not now", tableName: nil, bundle: bundle, value: "Not now", comment: "Permissios popup: Not now")
    }
    
    internal func setupUI() {
        switch type {
        case .locationAndNotifications:
            locationContainer.isHidden = false
            notificationsContainer.isHidden = false
        case .locationOnly:
            locationContainer.isHidden = false
            notificationsContainer.isHidden = true
        case .notificationsOnly:
            locationContainer.isHidden = true
            notificationsContainer.isHidden = false
        }
        
        explain.textColor = textColor
        explain.text = explainText
        footer.tintColor = textColor
        
        applyFont()
        
        location.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        location.setBackgroundImage(unknownButton, for: .normal)
        location.setTitle(locationText, for: .normal)
        notification.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        notification.setBackgroundImage(unknownButton, for: .normal)
        notification.setTitle(notificationsText, for: .normal)
        header.image = headerImage
        
        refreshButtons()

        footer.setTitle(notNowText, for: .normal)
    }
    
    private func applyFont() {
        if let regularFontName = NITUIAppearance.sharedInstance.regularFontName {
            explain.changeFont(to: regularFontName)
        }
        if let boldFontName = NITUIAppearance.sharedInstance.boldFontName {
            location.changeFont(to: boldFontName)
            notification.changeFont(to: boldFontName)
        }
        if let italicFontName = NITUIAppearance.sharedInstance.italicFontName {
            footer.changeFont(to: italicFontName)
        }
    }
    
    private func refreshButtons() {
        if #available(iOS 10.0, *) {
            permissionsManager.isNotificationAvailable({ (available) in
                if available {
                    self.confirmNotificationButton()
                } else {
                    self.unconfirmNotificationButton()
                }
            })
        } else {
            if permissionsManager.isNotificationAvailable() {
                confirmNotificationButton()
            } else {
                unconfirmNotificationButton()
            }
        }
        
        var authorizationStatus: CLAuthorizationStatus!
        switch locationType {
        case .always:
            authorizationStatus = .authorizedAlways
        case .whenInUse:
            authorizationStatus = .authorizedWhenInUse
        }
        
        if permissionsManager.isLocationGrantedAtLeast(minStatus: authorizationStatus) {
            confirmLocationButton()
        } else {
            unconfirmLocationButton()
        }
    }

    @IBAction func tapFooter(_ sender: Any) {
        dialogController?.dismiss()
    }

    fileprivate func callClosingDelegate() {
        let location = permissionsManager.isLocationGrantedAtLeast(minStatus: locationType.authorizationStatus)
        let notifications = permissionsManager.isNotificationAvailable()
        delegate?.dialogClosed?(locationGranted: location, notificationsGranted: notifications)
    }
    
    // MARK: - Permission buttons
    
    @IBAction func tapLocation(_ sender: Any) {
        permissionsManager.requestLocationPermission(minStatus: locationType.authorizationStatus)
    }
    
    @IBAction func tapNotifications(_ sender: Any) {
        permissionsManager.requestNotificationsPermission()
    }
    
    func confirmLocationButton() {
        location.setBackgroundImage(grantedButton, for: .normal)
        location.setTitleColor(UIColor.white, for: .normal)
        location.setImage(grantedIcon, for: .normal)
        footer.setTitle(closeText, for: .normal)
    }
    
    func unconfirmLocationButton() {
        location.setBackgroundImage(unknownButton, for: .normal)
        location.setTitleColor(UIColor.black, for: .normal)
        location.setImage(locationIcon, for: .normal)
    }
    
    func confirmNotificationButton() {
        notification.setBackgroundImage(grantedButton, for: .normal)
        notification.setTitleColor(UIColor.white, for: .normal)
        notification.setImage(grantedIcon, for: .normal)
        footer.setTitle(closeText, for: .normal)
    }
    
    func unconfirmNotificationButton() {
        notification.setBackgroundImage(unknownButton, for: .normal)
        notification.setTitleColor(UIColor.black, for: .normal)
        notification.setImage(notificationsIcon, for: .normal)
    }
    
    @objc public func show() {
        if let viewController = UIApplication.shared.keyWindow?.currentController() {
            self.show(fromViewController: viewController, configureDialog: nil)
        }
    }
    
    /// Present permissions view controller from the rootViewController if it exists
    @objc public func show(configureDialog: ((_ dialogController: NITDialogController) -> ())? = nil ) {
        if let viewController = UIApplication.shared.keyWindow?.currentController() {
            self.show(fromViewController: viewController, configureDialog: configureDialog)
        }
    }
    
    /**
     Present permissions view controller from a view controller
     - Parameter fromViewController: view controller used to present the permissions view controller
     */
    @objc public func show(fromViewController: UIViewController, configureDialog: ((_ dialogController: NITDialogController) -> ())? = nil) {
        let dialog = NITDialogController(viewController: self)
        if let configDlg = configureDialog {
            configDlg(dialog)
        }
        fromViewController.present(dialog, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

extension NITPermissionsViewController: NITPermissionsManagerDelegate {
    public func permissionsManager(_ manager: NITPermissionsManager, didGrantLocationAuthorization granted: Bool, withStatus status: CLAuthorizationStatus) {
        if (granted && permissionsManager.status(status, isAtLeast: locationType.authorizationStatus)) {
            confirmLocationButton()
        }
        delegate?.locationGranted?(granted)
        eventuallyClose()
    }
    
    public func permissionsManagerDidRequestNotificationPermissions(_ manager: NITPermissionsManager) {
        confirmNotificationButton()
        delegate?.notificationsGranted?(manager.isNotificationAvailable())
        eventuallyClose()
    }

    func eventuallyClose() {
        if autoCloseDialog == .on && checkPermissions() {
            dismiss(animated: true, completion: nil)
        }
    }

}
