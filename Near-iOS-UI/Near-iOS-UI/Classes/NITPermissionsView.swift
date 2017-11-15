//
//  NITPermissionsView.swift
//  NeariOSUI
//
//  Created by Nicola Ferruzzi on 15/11/2017.
//  Copyright © 2017 Near. All rights reserved.
//

import UIKit

class NITPermissionsView: UIView {

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var iconLocation: UIImageView!
    @IBOutlet weak var iconNotifications: UIImageView!
    @IBOutlet weak var iconBluetooth: UIImageView!
    @IBOutlet var backgroundView: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        let bundle = Bundle(for: NITPermissionsView.self)
        bundle.loadNibNamed("NITPermissions", owner: self, options: nil)
        addSubview(backgroundView)
        NSLayoutConstraint.activate([
            backgroundView.leftAnchor.constraint(equalTo: leftAnchor),
            backgroundView.rightAnchor.constraint(equalTo: rightAnchor),
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.heightAnchor.constraint(equalToConstant: 50.0),
        ])
    }
}
