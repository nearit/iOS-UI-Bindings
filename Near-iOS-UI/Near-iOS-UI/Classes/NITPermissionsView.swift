//
//  NITPermissionsView.swift
//  NeariOSUI
//
//  Created by Nicola Ferruzzi on 15/11/2017.
//  Copyright © 2017 Near. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth

@objc public enum NITPermissionsViewPermissions: NSInteger {
    case location = 0b001
    case notifications = 0b010
    case bluetooth = 0b100
    case locationAndNotifications = 0b011
    case notificationAndBluetooth = 0b110
    case locationAndBluetooth = 0b101
    case all = 0b111

    static public func |(lhs: NITPermissionsViewPermissions, rhs: NITPermissionsViewPermissions) -> NITPermissionsViewPermissions {
        let or = lhs.rawValue | rhs.rawValue
        return NITPermissionsViewPermissions(rawValue: or)!
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

    fileprivate func isGranted(permissionManager: NITPermissionsManager, minStatus: CLAuthorizationStatus ,btManager: CBPeripheralManager, completionHandler: @escaping (Bool) -> Void) {
        let hasLocation = contains(NITPermissionsViewPermissions.location)
        let hasNotification = contains(NITPermissionsViewPermissions.notifications)
        let hasBluetooth = contains(NITPermissionsViewPermissions.bluetooth)

        if hasBluetooth && btManager.state != .poweredOn {
            completionHandler(false)
            return
        }
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

public class NITPermissionsView: UIView, CBPeripheralManagerDelegate, NITPermissionsManagerDelegate, NITPermissionsViewControllerDelegate {

    @IBOutlet weak var permissionButton: NITPermissionBarButton!
    @IBOutlet weak var message: UILabel!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var leftImageView: UIImageView!
    
    @IBOutlet weak var centeredConstraint: NSLayoutConstraint!
    @IBOutlet weak var alignToBottomConstraint: NSLayoutConstraint!
    
    @objc public var locationType : NITPermissionsLocationType = .always

    private var btManager: CBPeripheralManager!
    private var permissionManager = NITPermissionsManager()
    private var heightConstraint: NSLayoutConstraint?
    private let height: CGFloat = 50.0
    private var debouncer: Timer?
    private var satisfied: NITPermissionsViewSatisfaction = .sad
    private var defaultSadImage: UIImage?
    private var defaultWorriedImage: UIImage?
    
    @objc public var refreshOnAppActivation: Bool = true
    
    @objc public var messageFont: UIFont? {
        didSet {
            message.font = messageFont
        }
    }
    @objc public var buttonFont: UIFont? {
        didSet {
            // button.titleLabel?.font = buttonFont
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

    @objc @IBInspectable public var messageColor: UIColor? {
        didSet {
            message.textColor = messageColor
        }
    }

    @objc @IBInspectable public var animateView: Bool = true

    @objc @IBInspectable public var permissionsRequired = NITPermissionsViewPermissions.all {
        didSet {
            refresh()
        }
    }

    @objc public var callbackOnPermissions: ((NITPermissionsView) -> Void)?

    @objc @IBInspectable public var buttonBackgroundImage: UIImage? {
        didSet {
            // button.setBackgroundImage(buttonBackgroundImage, for: .normal)
        }
    }

    @objc public var sadImage: UIImage? {
        get { return sadImage ?? defaultSadImage }
    }
    @objc public var worriedImage: UIImage? {
        get { return worriedImage ?? defaultWorriedImage }
    }
    
    @objc override public init(frame: CGRect) {
        super.init(frame: frame)
        btManager = CBPeripheralManager(delegate: self, queue: nil, options: [CBPeripheralManagerOptionShowPowerAlertKey: false])
        setup()
    }

    init(frame: CGRect,
         permissionManager: NITPermissionsManager?,
         btManager: CBPeripheralManager?) {
        super.init(frame: frame)
        self.permissionManager = permissionManager ?? NITPermissionsManager()
        self.btManager = btManager ?? CBPeripheralManager(delegate: self, queue: nil, options: [CBPeripheralManagerOptionShowPowerAlertKey: false])
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        btManager = CBPeripheralManager(delegate: self, queue: nil, options: [CBPeripheralManagerOptionShowPowerAlertKey: false])
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

        messageText = NSLocalizedString("Permission bar message", tableName: nil, bundle: bundle, value: "Please provide all required permissions", comment: "Permission bar message: provide all permissions")

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapBar(_:)))
        addGestureRecognizer(tapRecognizer)
        callbackOnPermissions = { (view: NITPermissionsView) -> Void in
            view.defaultCallback()
        }

        buttonBackgroundImage = UIImage.init(named: "filledWhite", in: bundle, compatibleWith: nil)
        defaultSadImage = UIImage.init(named: "whiteSad", in: bundle, compatibleWith: nil)
        defaultWorriedImage = UIImage.init(named: "whiteWorried", in: bundle, compatibleWith: nil)
        
        applyFont()
        // refresh()
        align()
        setNeedsLayout()
        
        permissionButton.addMissingConstraint(.notification)
        permissionButton.addMissingConstraint(.blueTooth)
        permissionButton.addMissingConstraint(.location)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationDidBecomeActive(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    private func applyFont() {
        if let messageFont = self.messageFont {
            message.font = messageFont
        } else {
            if let mediumFont = NITUIAppearance.sharedInstance.mediumFontName {
                message.font = UIFont.init(name: mediumFont, size: 13.0)
            }
        }
        
//        if let buttonFont = self.buttonFont {
//            button.titleLabel?.font = buttonFont
//        } else {
//            if let boldFont = NITUIAppearance.sharedInstance.boldFontName {
//                button.titleLabel?.font = UIFont.init(name: boldFont, size: 15.0)
//            }
//        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func applicationDidBecomeActive(_ notification: Notification) {
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
        // button.isHidden = permissionsRequired.toNITPermission() == nil
        var strongFailure = false
        var lightFailure = false
        
        let hasLocation = permissionsRequired.contains(NITPermissionsViewPermissions.location)
        let hasNotification = permissionsRequired.contains(NITPermissionsViewPermissions.notifications)
        let hasBluetooth = permissionsRequired.contains(NITPermissionsViewPermissions.bluetooth)
        
        
        if hasBluetooth && btManager.state != .poweredOn {
            strongFailure = true
        }
        if hasLocation && !permissionManager.isLocationGrantedAtLeast(minStatus: locationType.authorizationStatus) {
            let minRequirement = locationType
            let actualPermission = permissionManager.locationStatus()
            switch minRequirement {
            case .always:
                strongFailure = strongFailure || (actualPermission != .authorizedAlways && actualPermission != .authorizedWhenInUse)
                lightFailure = lightFailure || (actualPermission == .authorizedWhenInUse)
            case .whenInUse:
                strongFailure = strongFailure || (actualPermission != .authorizedAlways && actualPermission != .authorizedWhenInUse)
            }
        }
        
        if hasNotification {
            permissionManager.isNotificationAvailable { (granted) in
                strongFailure = strongFailure || !granted
                self.setBarStyle(strongFailure: strongFailure, lightFailure: lightFailure)
            }
        } else {
            setBarStyle(strongFailure: strongFailure, lightFailure: lightFailure)
        }
    }
    
    private func setBarStyle(strongFailure: Bool, lightFailure: Bool) {
        if (strongFailure) {
            backgroundColor = UIColor.sadRed
            leftImageView.image = sadImage
            delegate?.permissionView(self, didGrant: false)
        } else if (lightFailure) {
            backgroundColor = UIColor.worriedYellow
            leftImageView.image = worriedImage
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
        debouncer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(resize), userInfo: nil, repeats: false)
    }

    @objc private func resize() {
        permissionsRequired.isGranted(permissionManager: permissionManager, minStatus: locationType.authorizationStatus , btManager: btManager) { (granted) in
            let newHeight = granted ? 0.0 : self.height
            
            if self.animateView {
                UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [.curveEaseOut, .beginFromCurrentState, .allowUserInteraction], animations: { [weak self] () -> Void in
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

    public func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        refresh()
    }

    public func permissionsManager(_ manager: NITPermissionsManager, didGrantLocationAuthorization granted: Bool, withStatus status: CLAuthorizationStatus) {
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

