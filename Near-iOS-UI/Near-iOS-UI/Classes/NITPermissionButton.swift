//
//  NITPermissionButton.swift
//  NearUIBinding
//
//  Created by Nicola Ferruzzi on 20/11/2017.
//  Copyright © 2017 Near. All rights reserved.
//

import UIKit

class NITPermissionButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        if let image = imageView?.image {
            let margin = 30.0 - image.size.width / 2
            let tRect = titleRect(forContentRect: bounds)
            contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
            imageEdgeInsets = UIEdgeInsets(top: 0, left: margin, bottom: 0, right: 0)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: (bounds.width - tRect.width -  image.size.width - margin) / 2,
                                           bottom: 0, right: 0)
        }
    }
}
