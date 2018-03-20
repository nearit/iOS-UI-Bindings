//
//  NITPermissionsView.swift
//  NeariOSUI
//
//  Created by Nicola Ferruzzi on 15/11/2017.
//  Copyright © 2017 Near. All rights reserved.
//

import UIKit
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

    fileprivate func isGranted(permissionManager: NITPermissionsManager, btManager: CBPeripheralManager) -> Bool {
        let hasLocation = contains(NITPermissionsViewPermissions.location)
        let hasNotification = contains(NITPermissionsViewPermissions.notifications)
        let hasBluetooth = contains(NITPermissionsViewPermissions.bluetooth)

        if hasBluetooth && btManager.state != .poweredOn { return false }
        if hasLocation && !permissionManager.isLocationPartiallyGranted() { return false }
        if hasNotification && !permissionManager.isNotificationAvailable() { return false }

        return true
    }
}

@objc public enum NITPermissionsViewAlignement: NSInteger {
    case center
    case bottom
}

public protocol NITPermissionsViewDelegate: class {
    func permissionView(_ permissionView: NITPermissionsView, didGrant granted: Bool)
}

public class NITPermissionsView: UIView, CBPeripheralManagerDelegate, NITPermissionsManagerDelegate, NITPermissionsViewControllerDelegate {

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var iconLocation: UIImageView!
    @IBOutlet weak var iconNotifications: UIImageView!
    @IBOutlet weak var iconBluetooth: UIImageView!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var centerConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    private var btManager: CBPeripheralManager!
    private var permissionManager = NITPermissionsManager()
    private var heightConstraint: NSLayoutConstraint?
    private let height: CGFloat = 50.0
    private var debouncer: Timer?
    
    public weak var delegate: NITPermissionsViewDelegate?
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

    @objc public var messageFont: UIFont? {
        didSet {
            message.font = messageFont
        }
    }

    @objc @IBInspectable public var buttonText: String? {
        didSet {
            button.setTitle(buttonText, for: .normal)
        }
    }

    @objc @IBInspectable public var buttonColor: UIColor? {
        didSet {
            button.setTitleColor(buttonColor, for: .normal)
        }
    }

    @objc public var buttonFont: UIFont? {
        didSet {
            button.titleLabel?.font = buttonFont
        }
    }

    @objc @IBInspectable public var permissionAvailableColor: UIColor? = UIColor.white {
        didSet {
            refresh()
        }
    }

    @objc @IBInspectable public var permissionNotAvailableColor: UIColor? = UIColor.nearRed {
        didSet {
            refresh()
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
            button.setBackgroundImage(buttonBackgroundImage, for: .normal)
        }
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
        backgroundColor = backgroundColor ?? UIColor.nearBlack

        let bundle = Bundle.NITBundle(for: NITPermissionsView.self)
        bundle.loadNibNamed("NITPermissionsView", owner: self, options: nil)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.backgroundColor = .clear
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

        buttonText = NSLocalizedString("Permission bar button", tableName: nil, bundle: bundle, value: "OK", comment: "Permission bar button: OK")

        callbackOnPermissions = { (view: NITPermissionsView) -> Void in
            view.defaultCallback()
        }

        buttonBackgroundImage = UIImage.init(named: "filledWhite", in: bundle, compatibleWith: nil)

        refresh()
        align()
        setNeedsLayout()
    }
    
    private func align() {
        switch alignement {
        case .center:
            centerConstraint.priority = UILayoutPriority(rawValue: 1000)
            bottomConstraint.priority = UILayoutPriority(rawValue: 250)
        case .bottom:
            centerConstraint.priority = UILayoutPriority(rawValue: 250)
            bottomConstraint.priority = UILayoutPriority(rawValue: 1000)
        }
    }

    private func refresh() {
        if permissionManager.isLocationPartiallyGranted() {
            iconLocation.tintColor = permissionAvailableColor
        } else {
            iconLocation.tintColor = permissionNotAvailableColor
        }

        switch btManager.state {
        case .poweredOn:
            iconBluetooth.tintColor = permissionAvailableColor
        default:
            iconBluetooth.tintColor = permissionNotAvailableColor
        }

        if permissionManager.isNotificationAvailable() {
            iconNotifications.tintColor = permissionAvailableColor
        } else {
            iconNotifications.tintColor = permissionNotAvailableColor
        }

        iconLocation.isHidden = !permissionsRequired.contains(NITPermissionsViewPermissions.location)
        iconNotifications.isHidden = !permissionsRequired.contains(NITPermissionsViewPermissions.notifications)
        iconBluetooth.isHidden = !permissionsRequired.contains(NITPermissionsViewPermissions.bluetooth)

        button.isHidden = permissionsRequired.toNITPermission() == nil
        
        let granted = permissionsRequired.isGranted(permissionManager: permissionManager, btManager: btManager)
        delegate?.permissionView(self, didGrant: granted)

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
        let granted = permissionsRequired.isGranted(permissionManager: permissionManager, btManager: btManager)
        let newHeight = granted ? 0.0 : height

        if animateView {
            UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [.curveEaseOut, .beginFromCurrentState, .allowUserInteraction], animations: { [weak self] () -> Void in
                if let wself = self {
                    wself.heightConstraint!.constant = newHeight
                    wself.superview?.layoutIfNeeded()
                }
                }, completion: { _ in })
        } else {
            heightConstraint = heightAnchor.constraint(equalToConstant: newHeight)
        }
    }

    public func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        refresh()
    }

    func permissionsManager(_ manager: NITPermissionsManager, didGrantLocationAuthorization granted: Bool) {
        refresh()
    }

    func permissionsManagerDidRequestNotificationPermissions(_ manager: NITPermissionsManager) {
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

    @IBAction private func tapOK(_ sender: Any) {
        if let callbackOnPermissions = callbackOnPermissions {
            callbackOnPermissions(self)
        }
    }
}
