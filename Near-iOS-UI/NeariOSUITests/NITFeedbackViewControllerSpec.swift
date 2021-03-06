//
//  NITFeedbackViewControllerSpec.swift
//  NeariOSUITests
//
//  Created by francesco.leoni on 19/10/17.
//  Copyright © 2017 Near. All rights reserved.
//

import Quick
import Nimble
import FBSnapshotTestCase
import Nimble_Snapshots
@testable import NearITSDK
@testable import NearUIBinding

class NITFeedbackViewControllerSpec: QuickSpec {
    
    var recordingMode: Bool {
        return false
    }
    
    override func spec() {
        var feedbackVC: NITFeedbackViewController!
        let fakeNearManager = FakeNearManager()
        
        beforeEach {
            let feedback = NITFeedback()
            feedback.question = "Should i go on vacation?"
            feedbackVC = NITFeedbackViewController(feedback: feedback,
                                                   feedbackSendCallback: nil,
                                                   manager: fakeNearManager)
            
            //Trigger the view to load and assert that it's not nil
            expect(feedbackVC.view).notTo(beNil())
            expect(feedbackVC.stars).notTo(beNil())
        }
        
        describe("rating") {
            it("Rate nothing, send and comment should not be visible") {
                expect(feedbackVC.send).notTo(beNil())
                
                expect(feedbackVC.sendContainer.isHidden).to(beTrue())
                feedbackVC.commentViews.forEach({ expect($0.isHidden).to(beTrue())})
            }
            
            it("Rate something, comment and send should be visible") {
                expect(feedbackVC.sendContainer.isHidden).to(beTrue())
                feedbackVC.commentViews.forEach({ expect($0.isHidden).to(beTrue())})

                feedbackVC.stars[2].sendActions(for: .touchUpInside)
                
                feedbackVC.commentViews.forEach({ expect($0.isHidden).to(beFalse())})
                expect(feedbackVC.send.isHidden).to(beFalse())
            }

            it("Rate 0 special case, toggle/untoggle comment and send visibility") {
                expect(feedbackVC.sendContainer.isHidden).to(beTrue())
                feedbackVC.commentViews.forEach({ expect($0.isHidden).to(beTrue())})

                feedbackVC.stars[0].sendActions(for: .touchUpInside)
                feedbackVC.commentViews.forEach({ expect($0.isHidden).to(beFalse())})
                expect(feedbackVC.send.isHidden).to(beFalse())

                feedbackVC.stars[0].sendActions(for: .touchUpInside)
                expect(feedbackVC.sendContainer.isHidden).to(beTrue())
                feedbackVC.commentViews.forEach({ expect($0.isHidden).to(beTrue())})
            }

            it("Rate, comment hidden") {
                feedbackVC.commentVisibility = .hidden
                
                feedbackVC.stars[2].sendActions(for: .touchUpInside)
                feedbackVC.commentViews.forEach({ expect($0.isHidden).to(beTrue())})
            }

            it("Rate 0 special case, comment always visible support toggle") {
                feedbackVC.commentVisibility = .visible
                feedbackVC.commentViews.forEach({ expect($0.isHidden).to(beFalse())})

                feedbackVC.stars[0].sendActions(for: .touchUpInside)
                feedbackVC.commentViews.forEach({ expect($0.isHidden).to(beFalse())})

                feedbackVC.stars[0].sendActions(for: .touchUpInside)
                feedbackVC.commentViews.forEach({ expect($0.isHidden).to(beFalse())})
            }
            
            it("Rate 2 stars and send") {
                expect(feedbackVC.send).notTo(beNil())
                
                feedbackVC.stars[2].sendActions(for: .touchUpInside)
                feedbackVC.send.sendActions(for: .touchUpInside)
                
                expect(fakeNearManager.isSendEventCalled).to(beTrue())
            }
            
            it("Rate 2 stars, send with error should show retry and error text") {
                fakeNearManager.fakeSendEventError = true
                
                expect(feedbackVC.errorContainer.isHidden).to(beTrue())
                expect(feedbackVC.send.titleLabel?.text).to(match(feedbackVC.sendText))
                
                feedbackVC.stars[2].sendActions(for: .touchUpInside)
                feedbackVC.send.sendActions(for: .touchUpInside)
                
                expect(fakeNearManager.isSendEventCalled).to(beTrue())
                expect(feedbackVC.errorContainer.isHidden).to(beFalse())
                expect(feedbackVC.error.text).to(match(feedbackVC.errorText))
                expect(feedbackVC.send.titleLabel?.text).to(match(feedbackVC.retryText))
            }
        }
    }
    
    public func testDummy() {}
    
}

class FakeNearManager: NITManager {
    
    var fakeSendEventError = false
    var isSendEventCalled = false
    
    override func sendEvent(with event: NITEvent, completionHandler handler: ((Error?) -> Void)? = nil) {
        isSendEventCalled = true
        if fakeSendEventError {
            handler?(FakeManagerError.sendEventError)
        } else {
            handler?(nil)
        }
    }
}

enum FakeManagerError: Error {
    case sendEventError
}
