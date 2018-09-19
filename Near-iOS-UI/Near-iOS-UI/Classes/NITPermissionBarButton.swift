//
//  NITPermissionBarButton.swift
//  NearUIBinding
//
//  Created by Cattaneo Stefano on 16/07/2018.
//  Copyright © 2018 Near. All rights reserved.
//

import UIKit

public enum NITPermissionInfo {
    case blueTooth
    case location
    case notification
}

class NITPermissionBarButton: UIView {
    
    let permissionManager = NITPermissionsManager()
    let stackView = UIStackView()
    
    var alreadyMissing = [NITPermissionInfo]()
    
    @objc @IBInspectable public var missingLocationIcon: UIImage?
    @objc @IBInspectable public var missingBluetoothIcon: UIImage?
    @objc @IBInspectable public var missingNotificationIcon: UIImage?
    
    private var defaultMissingLocationIcon: UIImage?
    private var defaultMissingBluetoothIcon: UIImage?
    private var defaultMissingNotificationIcon: UIImage?
    
    private func getMissingLocationIcon() -> UIImage? {
        return missingLocationIcon ?? defaultMissingLocationIcon
    }
    
    private func getMissingBluetoothIcon() -> UIImage? {
        return missingBluetoothIcon ?? defaultMissingBluetoothIcon
    }
    
    private func getMissingNotificationIcon() -> UIImage? {
        return missingNotificationIcon ?? defaultMissingNotificationIcon
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
       defaultMissingBluetoothIcon = UIImage(named: "bluetoothBianco", in: Bundle.NITBundle(for: NITPermissionBarButton.self), compatibleWith: nil)
        defaultMissingLocationIcon = UIImage(named: "localizzazioneBianco", in: Bundle.NITBundle(for: NITPermissionBarButton.self), compatibleWith: nil)
        defaultMissingNotificationIcon = UIImage(named: "notificheBianco", in: Bundle.NITBundle(for: NITPermissionBarButton.self), compatibleWith: nil)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundColor = NITUIAppearance.sharedInstance.nearBlack()
        
        let halfHeight = layer.frame.height / 2
        layer.cornerRadius = halfHeight
        
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 8.0
        stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    public func resetConstraints() {
        alreadyMissing = [NITPermissionInfo]()
        for view in stackView.arrangedSubviews {
            view.removeFromSuperview()
        }
    }
    
    public func addMissingConstraint(_ permissionInfo : NITPermissionInfo) {
        if (alreadyMissing.contains(permissionInfo)) {
            return;
        }
        alreadyMissing.append(permissionInfo)
        if let image = imageFrom(permissionInfo) {
            let imageView = UIImageView()
            imageView.heightAnchor.constraint(equalToConstant: 18.0).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: 18.0).isActive = true
            imageView.contentMode = .scaleAspectFit
            imageView.image = image
            stackView.addArrangedSubview(imageView)
        }
    }
    
    func imageFrom(_ permissionInfo : NITPermissionInfo) -> UIImage? {
        switch permissionInfo {
        case .blueTooth:
            return getMissingBluetoothIcon()
        case .location:
            return getMissingLocationIcon()
        case .notification:
            return getMissingNotificationIcon()
        }
    }
    
}
