//
//  NITNotificationHistoryViewControllerTest.swift
//  NeariOSUITests
//
//  Created by francesco.leoni on 27/02/18.
//  Copyright © 2018 Near. All rights reserved.
//

import XCTest
import NearITSDK
@testable import NearUIBinding

class NITNotificationHistoryViewControllerTest: XCTestCase {
    
    var historyVC: NITNotificationHistoryViewController!
    let mockManager = MockHistoryManager()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        historyVC = NITNotificationHistoryViewController(manager: mockManager)
        let _ = historyVC.view
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAvailableItemsAll() {
        mockManager.items = itemsJSONAndFeedback()
        historyVC.availableItems = .all
        
        historyVC.refreshHistory()
        
        let numberOfSections = historyVC.numberOfSections(in: historyVC.tableView)
        XCTAssertTrue(numberOfSections == 2)
    }
    
    func testAvailableItemsOnlyJSON() {
        mockManager.items = itemsJSONAndFeedback()
        historyVC.availableItems = .customJSON
        
        historyVC.refreshHistory()
        
        let numberOfSections = historyVC.numberOfSections(in: historyVC.tableView)
        XCTAssertTrue(numberOfSections == 1)
    }
    
    func testAvailableItemsOnlyFeedback() {
        mockManager.items = itemsJSONAndFeedback()
        historyVC.availableItems = .feedback
        
        historyVC.refreshHistory()
        
        let numberOfSections = historyVC.numberOfSections(in: historyVC.tableView)
        XCTAssertTrue(numberOfSections == 1)
    }
    
    func testAvailableItemsNoJSONAndFeedback() {
        mockManager.items = itemsJSONAndFeedback()
        historyVC.availableItems = []
        
        historyVC.refreshHistory()
        
        let numberOfSections = historyVC.numberOfSections(in: historyVC.tableView)
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

class MockHistoryManager: NITManager {
    
    var items: [NITInboxItem]?
    
    override func inbox(completion: @escaping ([NITInboxItem]?, Error?) -> Void) {
        completion(items, nil)
    }
}
