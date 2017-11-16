//
//  MockCouponsNearManager.swift
//  UI-Swift-Sample
//
//  Created by francesco.leoni on 16/11/17.
//  Copyright © 2017 Near. All rights reserved.
//

import UIKit
import NearITSDK

class MockCouponsNearManager: NITManager {
    
    var coupons = [NITCoupon]()

    override func coupons(completionHandler handler: (([NITCoupon]?, Error?) -> Void)? = nil) {
        if let handler = handler {
            handler(coupons, nil)
        }
    }
}
