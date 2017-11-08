//
//  NITContentViewControllerSpec.swift
//  NeariOSUITests
//
//  Created by Nicola Ferruzzi on 06/11/2017.
//  Copyright © 2017 Near. All rights reserved.
//

import Quick
import Nimble
import FBSnapshotTestCase
import Nimble_Snapshots
@testable import NearITSDK
@testable import NeariOSUI

class NITContentViewControllerSpec: QuickSpec {

    var recordingMode: Bool {
        return false
    }

    func contentWithContentsOf(filename: String) -> NITContent? {
        let bundle = Bundle.main

        guard let path = bundle.path(forResource: filename,
                                     ofType: "json",
                                     inDirectory: nil) else { return nil }

        guard let japi = try? NITJSONAPI.init(contentsOfFile: path) else { return nil }
        japi.register(NITContent.self, forType: "contents")
        japi.register(NITCoupon.self, forType: "coupons")
        japi.register(NITImage.self, forType: "images")

        let reactions = japi.parseToArrayOfObjects()
        return reactions.last as? NITContent
    }

    override func spec() {
        var contentVC: NITContentViewController!

        describe("content") {
            beforeEach {
                let content = self.contentWithContentsOf(filename: "content")
                expect(content).notTo(beNil())

                contentVC = NITContentViewController(content: content!)
                expect(contentVC.view).notTo(beNil())
            }

            it("show the html and load a remote image") {
                contentVC.show()
                expect(contentVC.dialogController).notTo(beNil())
                expect(contentVC.dialogController?.view).notTo(beNil())

                // the webview is slow to render its content ..
                // sleeping the thread is not enough
                RunLoop.current.run(until: Date(timeIntervalSinceNow: 5.0))

                if (self.recordingMode) {
                    expect(contentVC.dialogController?.view).to(recordSnapshot(named: "has a complete webview"))
                } else {
                    expect(contentVC.dialogController?.view).to(haveValidSnapshot(named: "has a complete webview"))
                }
            }
        }
    }
}

