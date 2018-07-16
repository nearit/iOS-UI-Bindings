//
//  NITUIAppearance.swift
//  NearUIBinding
//
//  Created by Cattaneo Stefano on 03/07/2018.
//  Copyright © 2018 Near. All rights reserved.
//

import Foundation
import UIKit

public class NITUIAppearance {
    
    public static let sharedInstance = NITUIAppearance()
    
    public var regularFontName : String?
    public var mediumFontName : String?
    public var boldFontName : String?
    
    public var italicFontName : String?
    public var mediumItalicFontName: String?
    public var boldItalicFontName : String?
    
}

public extension UILabel {
    func changeFont(to fontName: String) {
        guard let customFont = UIFont(name: fontName, size: self.font.pointSize) else {
            return
        }
        self.font = customFont
    }
}

public extension UIButton {
    func changeFont(to fontName: String) {
        guard let labelFont = self.titleLabel?.font, let customFont = UIFont(name: fontName, size: labelFont.pointSize) else {
            return
        }
        self.titleLabel?.font = customFont
    }
}

extension UIFont {
    var isBold: Bool {
        return fontDescriptor.symbolicTraits.contains(.traitBold)
    }
    
    var isItalic: Bool {
        return fontDescriptor.symbolicTraits.contains(.traitItalic)
    }
}

extension UIColor {
    class var charcoalGray: UIColor {
        return UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
    }
    class var worriedYellow: UIColor {
        return UIColor(red: 1.0, green: 204/255, blue: 0/255, alpha: 1.0)
    }
    class var sadRed: UIColor {
        return UIColor(red: 1.0, green: 92/255, blue: 37/255, alpha: 1.0)
    }
    class var gray242: UIColor {
        return UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
    }
}
