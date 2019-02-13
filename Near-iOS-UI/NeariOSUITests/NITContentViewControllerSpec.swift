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
@testable import NearUIBinding

class NITContentViewControllerSpec: QuickSpec {

    var recordingMode: Bool {
        return false
    }

    override func spec() {
        var contentVC: NITContentViewController!

        describe("content") {
            beforeEach {
                let content = NITContent()
                content.content = "<a href='https://www.nearit.com'>LINK</a></br>Sopra la panca la capra campa sotto la panca la capra crepa."
                content.title = "Content title"
                contentVC = NITContentViewController(content: content)
                expect(contentVC.view).notTo(beNil())
            }

            it("show the html and load a remote image") {
                contentVC.show()
                expect(contentVC.dialogController).notTo(beNil())
                expect(contentVC.dialogController?.view).notTo(beNil())

                // the webview is slow to render its content ..
                // sleeping the thread is not enough
                RunLoop.current.run(until: Date(timeIntervalSinceNow: 5.0))

                if self.recordingMode {
                    expect(contentVC.dialogController?.view).to(recordSnapshot(named: "has a complete webview"))
                } else {
                    expect(contentVC.dialogController?.view).to(haveValidSnapshot(named: "has a complete webview"))
                }

                contentVC.dialogController?.dismiss()
            }
        }
    }
}
