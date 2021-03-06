//
//  NITPermissionsView.swift
//  NeariOSUI
//
//  Created by Nicola Ferruzzi on 15/11/2017.
//  Copyright © 2017 Near. All rights reserved.
//

import UIKit
import CoreLocation

@objc public enum NITPermissionsViewPermissions: NSInteger {
    case location = 0b001
    case notifications = 0b010
    @available(*, deprecated, message: "Bluetooth will always be considered on") case bluetooth = 0b100
    case locationAndNotifications = 0b011
    @available(*, deprecated, message: "Bluetooth will always be considered on") case notificationAndBluetooth = 0b110
    @available(*, deprecated, message: "Bluetooth will always be considered on") case locationAndBluetooth = 0b101
    case all = 0b111

    static public func | (lhs: NITPermissionsViewPermissions,
                          rhs: NITPermissionsViewPermissions) -> NITPermissionsViewPermissions {
        let orRawValue = lhs.rawValue | rhs.rawValue
        return NITPermissionsViewPermissions(rawValue: orRawValue)!
    }

    public func contains(_ lhs: NITPermissionsViewPermissions) -> Bool {
        return (rawValue & lhs.rawValue) != 0
    }

    public func toNITPermission() -> NITPermissionsType? {
        let hasLocation = contains(NITPermissionsViewPermissions.location)
        let hasNotification = contains(NITPermissionsViewPermissions.notifications)

        switch (hasLocation, hasNotification) {
        case (false, true):
            return NITPermissionsType.notificationsOnly
        case (true, false):
            return NITPermissionsType.locationOnly
        case (true, true):
            return NITPermissionsType.locationAndNotifications
        default:
            return nil
        }
    }

    fileprivate func isGranted(permissionManager: NITPermissionsManager,
                               minStatus: CLAuthorizationStatus,
                               completionHandler: @escaping (Bool) -> Void) {
        let hasLocation = contains(NITPermissionsViewPermissions.location)
        let hasNotification = contains(NITPermissionsViewPermissions.notifications)
       
        if hasLocation && !permissionManager.isLocationGrantedAtLeast(minStatus: minStatus) {
            completionHandler(false)
            return
        }
        if hasNotification {
            permissionManager.isNotificationAvailable { (granted) in
                completionHandler(granted)
            }
        } else {
            completionHandler(false)
        }
    }
}

@objc public enum NITPermissionsViewAlignement: NSInteger {
    case center
    case bottom
}

enum NITPermissionsViewSatisfaction: NSInteger {
    case happy
    case worried
    case sad
}

public protocol NITPermissionsViewDelegate: class {
    func permissionView(_ permissionView: NITPermissionsView, didGrant granted: Bool)
    func permissionView(_ permissionView: NITPermissionsView, colorDidChangeTo: UIColor)
}

public class NITPermissionsView: UIView, NITPermissionsManagerDelegate, NITPermissionsViewControllerDelegate {

    @IBOutlet weak var permissionButton: NITPermissionBarButton!
    @IBOutlet weak var message: UILabel!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var leftImageView: UIImageView!
    
    @IBOutlet weak var centeredConstraint: NSLayoutConstraint!
    @IBOutlet weak var alignToBottomConstraint: NSLayoutConstraint!
    
    @objc public var locationType: NITPermissionsLocationType = .always

    private var permissionManager = NITPermissionsManager()
    private var heightConstraint: NSLayoutConstraint?
    private let height: CGFloat = 50.0
    private var debouncer: Timer?
    private var satisfied: NITPermissionsViewSatisfaction = .sad

    @objc public var refreshOnAppActivation: Bool = true
    
    @objc public var messageFont: UIFont? {
        didSet {
            message.font = messageFont
        }
    }
    
    @objc public override var backgroundColor: UIColor? {
        didSet {
            if backgroundColor != oldValue, let UNWRPbackgroundColor = backgroundColor {
                delegate?.permissionView(self, colorDidChangeTo: UNWRPbackgroundColor)
            }
        }
    }
    
    public weak var delegate: NITPermissionsViewDelegate? {
        didSet {
            if let backColor = backgroundColor {
                delegate?.permissionView(self, colorDidChangeTo: backColor)
            }
        }
    }
    
    public var alignement: NITPermissionsViewAlignement = .center {
        didSet {
            align()
        }
    }

    @objc public var messageText: String? {
        didSet {
            message.text = messageText
        }
    }

    @IBInspectable public var messageColor: UIColor = NITUIAppearance.sharedInstance.nearWhite() {
        didSet {
            message.textColor = messageColor
        }
    }

    @IBInspectable public var animateView: Bool = true

    @IBInspectable public var permissionsRequired = NITPermissionsViewPermissions.all {
        didSet {
            refresh()
        }
    }

    @objc public var callbackOnPermissions: ((NITPermissionsView) -> Void)?

    @IBInspectable public var sadImage: UIImage?
    @IBInspectable public var worriedImage: UIImage?
    
    private var defaultSadImage: UIImage?
    private var defaultWorriedImage: UIImage?
    
    private func getSadImage() -> UIImage? {
        return sadImage ?? defaultSadImage
    }
    
    private func getWorriedImage() -> UIImage? {
        return worriedImage ?? defaultWorriedImage
    }
    
    @IBInspectable public var sadColor: UIColor?
    @IBInspectable public var worriedColor: UIColor?
    
    private var defaultSadColor = UIColor.sadRed
    private var defaultWorriedColor = UIColor.worriedYellow
    
    private func getSadColor() -> UIColor {
        return sadColor ?? defaultSadColor
    }
    
    private func getWorriedColor() -> UIColor {
        return worriedColor ?? defaultWorriedColor
    }
    
    @IBInspectable public var missingLocationIcon: UIImage?
    @IBInspectable public var missingBluetoothIcon: UIImage?
    @IBInspectable public var missingNotificationIcon: UIImage?
    
    @objc override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    init(frame: CGRect,
         permissionManager: NITPermissionsManager?) {
        super.init(frame: frame)
        self.permissionManager = permissionManager ?? NITPermissionsManager()
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
        permissionManager.delegate = self

        let bundle = Bundle.NITBundle(for: NITPermissionsView.self)
        bundle.loadNibNamed("NITPermissionsView", owner: self, options: nil)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundView)

        heightConstraint = heightAnchor.constraint(equalToConstant: 0.0)
        NSLayoutConstraint.activate([
            backgroundView.leftAnchor.constraint(equalTo: leftAnchor),
            backgroundView.rightAnchor.constraint(equalTo: rightAnchor),
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            heightConstraint!
        ])

        messageText = "nearit_ui_permission_bar_alert_text".nearUILocalized

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapBar(_:)))
        addGestureRecognizer(tapRecognizer)
        callbackOnPermissions = { (view: NITPermissionsView) -> Void in
            view.defaultCallback()
        }

        defaultSadImage = UIImage.init(named: "sadWhite", in: bundle, compatibleWith: nil)
        defaultWorriedImage = UIImage.init(named: "worriedWhite", in: bundle, compatibleWith: nil)
        
        message.textColor = messageColor
        
        applyFont()
        // refresh()
        align()
        setNeedsLayout()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationDidBecomeActive(_:)), name:
            UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    private func applyFont() {
        if let messageFont = self.messageFont {
            message.font = messageFont
        } else {
            if let mediumFont = NITUIAppearance.sharedInstance.mediumFontName {
                message.font = UIFont.init(name: mediumFont, size: message.font.pointSize)
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func applicationDidBecomeActive(_ notification: Notification) {
        permissionButton.missingBluetoothIcon = missingBluetoothIcon
        permissionButton.missingLocationIcon = missingLocationIcon
        permissionButton.missingNotificationIcon = missingNotificationIcon
        if refreshOnAppActivation {
            shouldRefresh()
        }
    }
    
    private func align() {
        switch alignement {
        case .center:
            centeredConstraint.priority = UILayoutPriority(rawValue: 1000)
            alignToBottomConstraint.priority = UILayoutPriority(rawValue: 250)
        case .bottom:
            centeredConstraint.priority = UILayoutPriority(rawValue: 250)
            alignToBottomConstraint.priority = UILayoutPriority(rawValue: 1000)
        }
    }
    
    public func shouldRefresh() {
        refresh()
    }

    private func refresh() {
        permissionButton.resetConstraints()
        
        var strongFailure = false
        var lightFailure = false
        
        let hasLocation = permissionsRequired.contains(NITPermissionsViewPermissions.location)
        let hasNotification = permissionsRequired.contains(NITPermissionsViewPermissions.notifications)
        
        if hasLocation && !permissionManager.isLocationGrantedAtLeast(minStatus: locationType.authorizationStatus) {
            let minRequirement = locationType
            let actualPermission = permissionManager.locationStatus()
            switch minRequirement {
            case .always:
                let failureShouldBeStrong = (actualPermission != .authorizedAlways &&
                    actualPermission != .authorizedWhenInUse)
                let failureShouldBeLight = actualPermission == .authorizedWhenInUse
                strongFailure = strongFailure || failureShouldBeStrong
                lightFailure = lightFailure || failureShouldBeLight
                if failureShouldBeStrong || failureShouldBeLight {
                    permissionButton.addMissingConstraint(.location)
                }
            case .whenInUse:
                let shouldFail = (actualPermission != .authorizedAlways && actualPermission != .authorizedWhenInUse)
                strongFailure = strongFailure || shouldFail
                if shouldFail {
                    permissionButton.addMissingConstraint(.location)
                }
            }
        }
        
        if hasNotification {
            permissionManager.isNotificationAvailable { (granted) in
                strongFailure = strongFailure || !granted
                if !granted {
                    self.permissionButton.addMissingConstraint(.notification)
                }
                self.setBarStyle(strongFailure: strongFailure, lightFailure: lightFailure)
            }
        } else {
            setBarStyle(strongFailure: strongFailure, lightFailure: lightFailure)
        }
    }
    
    private func setBarStyle(strongFailure: Bool, lightFailure: Bool) {
        if strongFailure {
            backgroundColor = getSadColor()
            leftImageView.image = getSadImage()
            delegate?.permissionView(self, didGrant: false)
        } else if lightFailure {
            backgroundColor = getWorriedColor()
            leftImageView.image = getWorriedImage()
            delegate?.permissionView(self, didGrant: false)
        } else {
            delegate?.permissionView(self, didGrant: true)
            // all good
        }
        
        debounceResize()
    }

    private func debounceResize() {
        // Debounce resize changes to avoid fast show-hide of the view.
        // This problem usually happens at the beginning, when iOS permissions state are not ready
        // causing the view to prompt for them and suddenly hide cause the "real states" become
        // available.
        debouncer?.invalidate()
        debouncer = Timer.scheduledTimer(timeInterval: 0.5, target: self,
                                         selector: #selector(resize), userInfo: nil, repeats: false)
    }

    @objc private func resize() {
        permissionsRequired.isGranted(permissionManager: permissionManager,
                                      minStatus: locationType.authorizationStatus) { (granted) in
            let newHeight = granted ? 0.0 : self.height
            
            if self.animateView {
                UIView.animate(
                    withDuration: 0.4, delay: 0.0,
                    usingSpringWithDamping: 1.0,
                    initialSpringVelocity: 0.0,
                    options: [.curveEaseOut, .beginFromCurrentState, .allowUserInteraction],
                    animations: { [weak self] () -> Void in
                        if let wself = self {
                            wself.heightConstraint!.constant = newHeight
                            wself.superview?.layoutIfNeeded()
                        }
                    }, completion: { _ in })
            } else {
                self.heightConstraint = self.heightAnchor.constraint(equalToConstant: newHeight)
            }
        }
    }

    public func permissionsManager(_ manager: NITPermissionsManager,
                                   didGrantLocationAuthorization granted: Bool,
                                   withStatus status: CLAuthorizationStatus) {
        refresh()
    }

    public func permissionsManagerDidRequestNotificationPermissions(_ manager: NITPermissionsManager) {
        refresh()
    }

    public func notificationsGranted(_ granted: Bool) {
        refresh()
    }

    private func defaultCallback() {
        if let permissions = permissionsRequired.toNITPermission() {
            let aViewController = NITPermissionsViewController(type: permissions)
            aViewController.delegate = self
            aViewController.show()
        }
    }

    @IBAction private func tapBar(_ sender: Any) {
        if let callbackOnPermissions = callbackOnPermissions {
            callbackOnPermissions(self)
        }
    }
}
