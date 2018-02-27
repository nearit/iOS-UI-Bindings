//
//  NITInboxListViewControllerTest.swift
//  NeariOSUITests
//
//  Created by francesco.leoni on 27/02/18.
//  Copyright © 2018 Near. All rights reserved.
//

import XCTest
import NearITSDK
@testable import NearUIBinding

class NITInboxListViewControllerTest: XCTestCase {
    
    var inboxVC: NITInboxListViewController!
    let mockManager = MockInboxManager()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        inboxVC = NITInboxListViewController(manager: mockManager)
        let _ = inboxVC.view
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAvailableItemsAll() {
        mockManager.items = itemsJSONAndFeedback()
        inboxVC.availableItems = .all
        
        inboxVC.refreshInbox()
        
        let numberOfSections = inboxVC.numberOfSections(in: inboxVC.tableView)
        XCTAssertTrue(numberOfSections == 2)
    }
    
    func testAvailableItemsOnlyJSON() {
        mockManager.items = itemsJSONAndFeedback()
        inboxVC.availableItems = .customJSON
        
        inboxVC.refreshInbox()
        
        let numberOfSections = inboxVC.numberOfSections(in: inboxVC.tableView)
        XCTAssertTrue(numberOfSections == 1)
    }
    
    func testAvailableItemsOnlyFeedback() {
        mockManager.items = itemsJSONAndFeedback()
        inboxVC.availableItems = .feedback
        
        inboxVC.refreshInbox()
        
        let numberOfSections = inboxVC.numberOfSections(in: inboxVC.tableView)
        XCTAssertTrue(numberOfSections == 1)
    }
    
    func testAvailableItemsNoJSONAndFeedback() {
        mockManager.items = itemsJSONAndFeedback()
        inboxVC.availableItems = []
        
        inboxVC.refreshInbox()
        
        let numberOfSections = inboxVC.numberOfSections(in: inboxVC.tableView)
        XCTAssertTrue(numberOfSections == 0)
    }
    
    func itemsJSONAndFeedback() -> [NITInboxItem] {
        let customJson = NITCustomJSON()
        let feedback = NITFeedback()
        
        let itemJson = NITInboxItem()
        itemJson.reactionBundle = customJson
        let itemFeedback = NITInboxItem()
        itemFeedback.reactionBundle = feedback
        
        return [itemJson, itemFeedback]
    }
}

class MockInboxManager: NITManager {
    
    var items: [NITInboxItem]?
    
    override func inbox(completion: @escaping ([NITInboxItem]?, Error?) -> Void) {
        completion(items, nil)
    }
}
