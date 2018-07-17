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
