//
//  NITPermissionsView.swift
//  NeariOSUI
//
//  Created by Nicola Ferruzzi on 15/11/2017.
//  Copyright © 2017 Near. All rights reserved.
//

import UIKit
import CoreBluetooth

class NITPermissionsView: UIView, CBPeripheralManagerDelegate, NITPermissionsManagerDelegate {

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var iconLocation: UIImageView!
    @IBOutlet weak var iconNotifications: UIImageView!
    @IBOutlet weak var iconBluetooth: UIImageView!
    @IBOutlet var backgroundView: UIView!

    private var btManager: CBPeripheralManager!
    private var permissionManager = NITPermissionsManager()

    public var messageText: String?
    public var buttonText: String?

    override init(frame: CGRect) {
        super.init(frame: frame)
        btManager = CBPeripheralManager.init(delegate: self, queue: nil)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        btManager = CBPeripheralManager.init(delegate: self, queue: nil)
        setup()
    }

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        permissionManager.delegate = self
        backgroundColor = .orange

        let bundle = Bundle(for: NITPermissionsView.self)

        bundle.loadNibNamed("NITPermissionsView", owner: self, options: nil)
        addSubview(backgroundView)
        NSLayoutConstraint.activate([
            backgroundView.leftAnchor.constraint(equalTo: leftAnchor),
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.widthAnchor.constraint(equalTo: widthAnchor),
            backgroundView.heightAnchor.constraint(equalToConstant: 50.0),
        ])

        messageText = NSLocalizedString("Permission bar message", tableName: nil, bundle: bundle, value: "Plese provide all required permissions", comment: "Permission bar message: provide all permissions")

        buttonText = NSLocalizedString("Permission bar button", tableName: nil, bundle: bundle, value: "OK", comment: "Permission bar button: OK")

        refresh()
        setNeedsLayout()
    }

    private func refresh() {
        if permissionManager.isLocationPartiallyGranted() {
            iconLocation.tintColor = .white
        } else {
            iconLocation.tintColor = UIColor.nearRed
        }

        switch btManager.state {
        case .poweredOn:
            iconBluetooth.tintColor = .white
        default:
            iconBluetooth.tintColor = UIColor.nearRed
        }

        if permissionManager.isNotificationAvailable() {
            iconNotifications.tintColor = .white
        } else {
            iconNotifications.tintColor = UIColor.nearRed
        }

        message.text = messageText
        button.setTitle(buttonText, for: .normal)
    }

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        refresh()
    }

    func permissionsManager(_ manager: NITPermissionsManager, didGrantLocationAuthorization granted: Bool) {
        refresh()
    }

    func permissionsManagerDidRequestNotificationPermissions(_ manager: NITPermissionsManager) {
        refresh()
    }

}
