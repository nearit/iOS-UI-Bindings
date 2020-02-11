//
//  String+NearUIBinding.swift
//  NearUIBinding
//
//  Created by Cattaneo Stefano on 11/02/2020.
//  Copyright © 2020 Near. All rights reserved.
//

import Foundation

extension String {
    static let stringTableName = "NearUIBinding"
    public var nearUILocalized: String {
        let mainBundleLocalized = NSLocalizedString(self,
                                                    tableName: String.stringTableName,
                                                    bundle: Bundle.main,
                                                    value: self,
                                                    comment: "")
        if mainBundleLocalized != self {
            return mainBundleLocalized
        }
        return NSLocalizedString(self,
                                 tableName: String.stringTableName,
                                 bundle: Bundle(for: NITCouponViewController.self),
                                 value: self,
                                 comment: "")
    }
}
