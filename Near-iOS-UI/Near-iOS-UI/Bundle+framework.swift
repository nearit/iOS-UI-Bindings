//
//  Bundle+framework.swift
//  NearUIBinding
//
//  Created by Nicola Ferruzzi on 18/11/2017.
//  Copyright © 2017 Near. All rights reserved.
//

import Foundation

public extension Bundle {
    static func NITBundle(for aClass: Swift.AnyClass) -> Bundle {
        let bundle = Bundle(for: aClass)
        if let bundleUrl = bundle.url(forResource: "NearUIBinding", withExtension: "bundle") {
            return Bundle(url: bundleUrl)!
        }
        return bundle
    }
}
