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
            let tr = titleRect(forContentRect: bounds)
            contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
            imageEdgeInsets = UIEdgeInsetsMake(0, margin, 0, 0)
            titleEdgeInsets = UIEdgeInsetsMake(0, (bounds.width - tr.width -  image.size.width - margin) / 2, 0, 0)
        }
    }
}
