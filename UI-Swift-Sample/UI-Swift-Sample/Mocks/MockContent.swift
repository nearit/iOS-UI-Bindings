//
//  MockContent.swift
//  UI-Swift-Sample
//
//  Created by francesco.leoni on 22/03/18.
//  Copyright © 2018 Near. All rights reserved.
//

import UIKit
import NearITSDK

class MockContent: NITContent {
    
    var mockLink: NITContentLink?
    var mockImage: NITImage?

    override var link: NITContentLink? {
        get {
            return mockLink
        }
    }
    
    override var image: NITImage? {
        get {
            return mockImage
        }
    }
}
