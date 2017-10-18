//
//  AppColors.swift
//  Near-iOS-UI
//
//  Created by francesco.leoni on 31/08/17.
//  Copyright © 2017 Near. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    @nonobjc class var nearWarmGrey: UIColor {
        return UIColor(white: 119.0 / 255.0, alpha: 1.0)
    }

    @nonobjc class var nearRed: UIColor {
        return UIColor(red: 229.0 / 255.0, green: 77.0 / 255.0, blue: 76.0 / 255.0, alpha: 1.0)
    }

    @nonobjc class var nearDialogBackground: UIColor {
        return UIColor.init(white: 0.0, alpha: 0.35)
    }
}
