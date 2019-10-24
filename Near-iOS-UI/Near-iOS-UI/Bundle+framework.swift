//
//  Bundle+framework.swift
//  NearUIBinding
//
//  Created by Nicola Ferruzzi on 18/11/2017.
//  Copyright © 2017 Near. All rights reserved.
//

import Foundation
import UIKit

public extension Bundle {
    static func NITBundle(for aClass: Swift.AnyClass) -> Bundle {
        let bundle = Bundle(for: aClass)
        if let bundleUrl = bundle.url(forResource: "NearUIBinding", withExtension: "bundle") {
            return Bundle(url: bundleUrl)!
        }
        return bundle
    }
}

public extension UIView {
    func setRoundedView() {
        layer.masksToBounds = true
        switch NITUIAppearance.sharedInstance.buttonLook() {
        case .fullRound:
            let number = layer.frame.height / 2
            layer.cornerRadius = number
        case .radiusOf(let radius):
            layer.cornerRadius = radius
        }
        layoutIfNeeded()
    }
}
