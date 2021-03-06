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
        switch self {
        case .always:
            return .authorizedAlways
        case .whenInUse:
            return .authorizedWhenInUse
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
    @IBOutlet weak var location: NITMultilineButton!
    @IBOutlet weak var notification: NITMultilineButton!
    @IBOutlet weak var footer: UIButton!
    @IBOutlet weak var header: UIImageView!
    @IBOutlet weak var locationContainer: UIView!
    @IBOutlet weak var notificationsContainer: UIView!

    @objc public var type: NITPermissionsType
    @objc public var locationType: NITPermissionsLocationType
    @objc public var autoStartRadar: NITPermissionsAutoStartRadarType
    @objc public var autoCloseDialog: NITPermissionsAutoCloseDialog

    @objc public var grantedIcon: UIImage!
    @objc public var headerImage: UIImage!
    @objc public var textColor: UIColor!
    @objc public var notificationsIcon: UIImage!
    @objc public var locationIcon: UIImage!

    @objc public var locationText: String!
    @objc public var locationAlways: String!
    @objc public var locationInUse: String!
    @objc public var locationNever: String!
    @objc public var notificationsText: String!
    @objc public var explainText = "nearit_ui_permissions_explanation_text".nearUILocalized
    @objc public var closeText = "nearit_ui_close_permissions_text".nearUILocalized
    @objc public var notNowText = "nearit_ui_close_permissions_text_default".nearUILocalized
    
    @objc public var happyImage: UIImage?
    @objc public var worriedImage: UIImage?
    @objc public var sadImage: UIImage?
    
    @objc public var checkedButtonColor: UIColor = UIColor.gray242
    @objc public var uncheckedButtonColor: UIColor = NITUIAppearance.sharedInstance.nearBlack()

    @objc public var refreshOnAppActivation: Bool = true
    @objc public weak var delegate: NITPermissionsViewControllerDelegate?

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationDidBecomeActive(_:)), name:
            UIApplication.didBecomeActiveNotification, object: nil)
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if autoStartRadar == .on {
            checkPermissions { (granted) in
                if granted {
                    let manager = NITManager.default()
                    manager.start()
                }
            }
        }
        callClosingDelegate()
        NotificationCenter.default.removeObserver(self)
    }

    @objc public func checkPermissions(_ completionHandler: @escaping (Bool) -> Void) {
        switch type {
        case .notificationsOnly:
            permissionsManager.isNotificationAvailable(completionHandler)
        case .locationOnly:
            completionHandler(permissionsManager.isLocationGrantedAtLeast(minStatus: locationType.authorizationStatus))
        case .locationAndNotifications:
            if permissionsManager.isLocationGrantedAtLeast(minStatus: locationType.authorizationStatus) {
                permissionsManager.isNotificationAvailable(completionHandler)
            } else {
                completionHandler(false)
            }
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

        grantedIcon = UIImage(named: "charcoalTick", in: bundle, compatibleWith: nil)
        headerImage = UIImage(named: "permissionsBanner", in: bundle, compatibleWith: nil)
        
        textColor = NITUIAppearance.sharedInstance.nearGrey()

        locationText = NSLocalizedString("Permissions popup: LOCATION", tableName: nil,
                                         bundle: bundle, value: "LOCATION",
                                         comment: "Permissions popup: LOCATION")
        notificationsText = NSLocalizedString("Permissions popup: NOTIFICATIONS", tableName: nil,
                                              bundle: bundle, value: "NOTIFICATIONS",
                                              comment: "Permissions popup: NOTIFICATIONS")
        locationNever = NSLocalizedString("Permission popup: LOCATION NEVER", tableName: nil,
                                          bundle: bundle, value: "never",
                                          comment: "Permission popup: LOCATION NEVER")
        locationInUse = NSLocalizedString("Permission popup: LOCATION IN USE", tableName: nil,
                                          bundle: bundle, value: "while using the app",
                                          comment: "Permission popup: LOCATION IN USE")
        locationAlways = NSLocalizedString("Permission popup: LOCATION ALWAYS", tableName: nil,
                                           bundle: bundle, value: "always",
                                           comment: "Permission popup: LOCATION ALWAYS")
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
        notification.setLabel(notificationsText)
        location.setLabel(locationText)
        
        notification.happyImage = happyImage
        notification.worriedImage = worriedImage
        notification.sadImage = sadImage
        location.happyImage = happyImage
        location.worriedImage = worriedImage
        location.sadImage = sadImage
        
        applyFont()
        
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
        permissionsManager.isNotificationStatusDetermined { (isDetermined) in
            if isDetermined {
                self.permissionsManager.isNotificationAvailable({ (available) in
                    if available {
                        self.confirmNotificationButton()
                    } else {
                        self.unconfirmNotificationButton()
                    }
                })
            } else {
                self.setNotificationUndetermined()
            }
        }
        
        let locationStatus = permissionsManager.locationStatus()
        switch locationStatus {
        case .notDetermined:
            setLocationNotDetermined()
        case .authorizedAlways:
            confirmLocationButton()
        case .authorizedWhenInUse:
            if locationType == .always {
                setLocationOnlyInUse()
            } else {
                confirmLocationButton()
            }
        case .denied:
            unconfirmLocationButton()
        default:
            unconfirmLocationButton()
        }
    }

    @IBAction func tapFooter(_ sender: Any) {
        dialogController?.dismiss()
    }

    fileprivate func callClosingDelegate() {
        let location = permissionsManager.isLocationGrantedAtLeast(minStatus: locationType.authorizationStatus)
        permissionsManager.isNotificationAvailable { (granted) in
            self.delegate?.dialogClosed?(locationGranted: location, notificationsGranted: granted)
        }
    }
    
    // MARK: - Permission buttons
    
    @IBAction func tapLocation(_ sender: Any) {
        permissionsManager.requestLocationPermission(minStatus: locationType.authorizationStatus)
    }
    
    @IBAction func tapNotifications(_ sender: Any) {
        permissionsManager.requestNotificationsPermission()
    }
    
    func confirmLocationButton() {
        // permission is granted
        location.setColor(checkedButtonColor)
        location.firstLineLabel.textColor = NITUIAppearance.sharedInstance.nearBlack()
        location.secondLineLabel.textColor = NITUIAppearance.sharedInstance.nearBlack()
        location.leftImage = grantedIcon
        location.leftImageView.heightAnchor.constraint(equalToConstant: 15.0).isActive = true
        location.leftImageView.widthAnchor.constraint(equalToConstant: 15.0).isActive = true
        location.makeHappy()
        location.setLabel(locationText, secondLine: locationAlways)
        footer.setTitle(closeText, for: .normal)
    }
    
    func unconfirmLocationButton() {
        location.setColor(uncheckedButtonColor)
        location.firstLineLabel.textColor = NITUIAppearance.sharedInstance.nearWhite()
        location.secondLineLabel.textColor = NITUIAppearance.sharedInstance.nearWhite()
        location.makeSad()
        location.setLabel(locationText, secondLine: locationNever)
    }
    
    func setLocationNotDetermined() {
        location.setColor(uncheckedButtonColor)
        location.firstLineLabel.textColor = NITUIAppearance.sharedInstance.nearWhite()
        location.secondLineLabel.textColor = NITUIAppearance.sharedInstance.nearWhite()
        location.rightImage = nil
        location.setLabel(locationText)
    }
    
    func setLocationOnlyInUse() {
        location.setColor(uncheckedButtonColor)
        location.firstLineLabel.textColor = NITUIAppearance.sharedInstance.nearWhite()
        location.secondLineLabel.textColor = NITUIAppearance.sharedInstance.nearWhite()
        location.makeWorried()
        location.setLabel(locationText, secondLine: locationInUse)
    }
    
    func confirmNotificationButton() {
        notification.firstLineLabel.textColor = NITUIAppearance.sharedInstance.nearBlack()
        notification.setColor(checkedButtonColor)
        notification.leftImage = grantedIcon
        notification.leftImageView.heightAnchor.constraint(equalToConstant: 15.0).isActive = true
        notification.leftImageView.widthAnchor.constraint(equalToConstant: 15.0).isActive = true
        notification.makeHappy()
        footer.setTitle(closeText, for: .normal)
    }
    
    func setNotificationUndetermined() {
        notification.setColor(uncheckedButtonColor)
        notification.firstLineLabel.textColor = NITUIAppearance.sharedInstance.nearWhite()
    }
    
    func unconfirmNotificationButton() {
        notification.setColor(uncheckedButtonColor)
        notification.firstLineLabel.textColor = NITUIAppearance.sharedInstance.nearWhite()
        notification.makeSad()
    }
    
    @objc public func show() {
        guard let viewController = UIApplication.shared.keyWindow?.currentController() else {
            NSLog("WARNING: The app has no view hierarchy yet! If you are showing our viewController inside viewDidLoad(), you should move it to viewDidAppear().")
            return
        }
        self.show(fromViewController: viewController, configureDialog: nil)
    }
    
    /// Present permissions view controller from the rootViewController if it exists
    @objc public func show(configureDialog: ((_ dialogController: NITDialogController) -> Void)? = nil ) {
        guard let viewController = UIApplication.shared.keyWindow?.currentController() else {
            NSLog("WARNING: The app has no view hierarchy yet! If you are showing our viewController inside viewDidLoad(), you should move it to viewDidAppear().")
            return
        }
        self.show(fromViewController: viewController, configureDialog: configureDialog)
    }
    
    /**
     Present permissions view controller from a view controller
     - Parameter fromViewController: view controller used to present the permissions view controller
     */
    @objc public func show(fromViewController: UIViewController,
                           configureDialog: ((_ dialogController: NITDialogController) -> Void)? = nil) {
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
    public func permissionsManager(_ manager: NITPermissionsManager,
                                   didGrantLocationAuthorization granted: Bool,
                                   withStatus status: CLAuthorizationStatus) {
        delegate?.locationGranted?(granted)
        guard self.isViewLoaded else { return }
        if granted && permissionsManager.status(status, isAtLeast: locationType.authorizationStatus) {
            confirmLocationButton()
        }
        eventuallyClose()
    }
    
    public func permissionsManagerDidRequestNotificationPermissions(_ manager: NITPermissionsManager) {
        if self.isViewLoaded {
            refreshButtons()
        }
        manager.isNotificationAvailable { (granted) in
            self.delegate?.notificationsGranted?(granted)
            self.eventuallyClose()
        }
        
    }

    func eventuallyClose() {
        if autoCloseDialog == .on {
            checkPermissions { (granted) in
                if granted {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
}
