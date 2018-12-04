//
//  NITUIAppearance.swift
//  NearUIBinding
//
//  Created by Cattaneo Stefano on 03/07/2018.
//  Copyright © 2018 Near. All rights reserved.
//

import Foundation
import UIKit

public class NITUIAppearance: NSObject {
    
    @objc public static let sharedInstance = NITUIAppearance()
    
    @objc public var regularFontName : String?
    @objc public var mediumFontName : String?
    @objc public var boldFontName : String?
    
    @objc public var italicFontName : String?
    @objc public var mediumItalicFontName: String?
    @objc public var boldItalicFontName : String?
    
    @objc public var globalBlackColor : UIColor?
    private let defaultGlobalBlackColor = UIColor.nearBlack
    public func nearBlack() -> UIColor {
        return globalBlackColor ?? defaultGlobalBlackColor
    }
    
    @objc public var globalWhiteColor : UIColor?
    private let defaultGlobalWhiteColor = UIColor.white
    public func nearWhite() -> UIColor {
        return globalWhiteColor ?? defaultGlobalWhiteColor
    }
    
    @objc public var globalGreyColor : UIColor?
    private let defaultGlobalGreyColor = UIColor.nearGrey
    public func nearGrey() -> UIColor {
        return globalGreyColor ?? defaultGlobalGreyColor
    }
    
    @objc public var globalGreenColor : UIColor?
    private let defaultGlobalGreenColor = UIColor.nearGreen
    public func nearGreen() -> UIColor {
        return globalGreenColor ?? defaultGlobalGreenColor
    }
    
    @objc public var globalRedColor : UIColor?
    private let defaultGlobalRedColor = UIColor.nearRed
    public func nearRed() -> UIColor {
        return globalRedColor ?? defaultGlobalRedColor
    }
    
    @objc public var couponDateFormatter : DateFormatter?
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
