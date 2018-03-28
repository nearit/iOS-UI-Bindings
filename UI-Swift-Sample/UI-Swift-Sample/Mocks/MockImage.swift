//
//  MockImage.swift
//  UI-Swift-Sample
//
//  Created by francesco.leoni on 22/03/18.
//  Copyright © 2018 Near. All rights reserved.
//

import UIKit
import NearITSDK

class MockImage: NITImage {
    
    var mockUrl: URL?

    override func smallSizeURL() -> URL? {
        return mockUrl
    }
    
    override func url() -> URL? {
        return mockUrl
    }
}
