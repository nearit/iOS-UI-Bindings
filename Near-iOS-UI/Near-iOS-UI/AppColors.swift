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

    @nonobjc class var nearRed: UIColor {
        return UIColor(red: 229.0 / 255.0, green: 77.0 / 255.0, blue: 76.0 / 255.0, alpha: 1.0)
    }
    
    @nonobjc class var nearGreen: UIColor {
        return UIColor(red: 104.0 / 255.0, green: 198.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0)
    }

    @nonobjc class var nearDialogBackground: UIColor {
        return UIColor.init(white: 0.0, alpha: 0.35)
    }

    @nonobjc class var nearPushedBackground: UIColor {
        return UIColor.init(white: 242.0 / 255.0, alpha: 1.0)
    }

    @nonobjc class var nearBlack: UIColor {
        return UIColor(white: 51.0 / 255.0, alpha: 1.0)
    }
    
    @nonobjc class var nearGrey: UIColor {
        return UIColor(white: 119 / 255, alpha: 1.0)
    }
    
    @nonobjc class var worriedYellow: UIColor {
        return UIColor(red: 1.0, green: 149/255, blue: 0/255, alpha: 1.0)
    }
    
    @nonobjc class var sadRed: UIColor {
        return UIColor(red: 1.0, green: 64/255, blue: 37/255, alpha: 1.0)
    }
    
    @nonobjc class var gray242: UIColor {
        return UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
    }
}
