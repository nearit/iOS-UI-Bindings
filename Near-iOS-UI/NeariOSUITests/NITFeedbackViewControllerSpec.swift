//
//  NITFeedbackViewControllerSpec.swift
//  NeariOSUITests
//
//  Created by francesco.leoni on 19/10/17.
//  Copyright © 2017 Near. All rights reserved.
//

import Quick
import Nimble
@testable import NearITSDK
@testable import NeariOSUI

class NITFeedbackViewControllerSpec: QuickSpec {
    
    override func spec() {
        var feedbackVC: NITFeedbackViewController!
        let fakeNearManager = FakeNearManager()
        
        beforeEach {
            let feedback = NITFeedback()
            feedback.question = "Should i go on vacation?"
            feedbackVC = NITFeedbackViewController(feedback: feedback, manager: fakeNearManager)
            
            //Trigger the view to load and assert that it's not nil
            expect(feedbackVC.view).notTo(beNil())
            expect(feedbackVC.stars).notTo(beNil())
        }
        
        describe("rating") {
            it("Rate nothing and send") {
                expect(feedbackVC.send).notTo(beNil())
                
                feedbackVC.send.sendActions(for: .touchUpInside)
                
                expect(fakeNearManager.isSendEventCalled).to(beFalse()) // Should not send feedback
            }
            
            it("Rate 2 stars and send") {
                expect(feedbackVC.send).notTo(beNil())
                
                feedbackVC.stars[2].sendActions(for: .touchUpInside)
                feedbackVC.send.sendActions(for: .touchUpInside)
                
                expect(fakeNearManager.isSendEventCalled).to(beTrue())
            }
        }
    }
    
    public func testDummy() {}
    
}

class FakeNearManager: NITManager {
    
    var isSendEventCalled = false
    
    override func sendEvent(with event: NITEvent, completionHandler handler: ((Error?) -> Void)? = nil) {
        isSendEventCalled = true
    }
}
