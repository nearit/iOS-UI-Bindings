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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundColor = UIColor.charcoalGray
        
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
        for view in stackView.arrangedSubviews {
            view.removeFromSuperview()
        }
    }
    
    public func addMissingConstraint(_ permissionInfo : NITPermissionInfo) {
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
            return UIImage(named: "bluetoothBianco", in: Bundle.NITBundle(for: NITPermissionBarButton.self), compatibleWith: nil)
        case .location:
            return UIImage(named: "localizzazioneBianco", in: Bundle.NITBundle(for: NITPermissionBarButton.self), compatibleWith: nil)
        case .notification:
            return UIImage(named: "notificheBianco", in: Bundle.NITBundle(for: NITPermissionBarButton.self), compatibleWith: nil)
        }
    }
    
}
