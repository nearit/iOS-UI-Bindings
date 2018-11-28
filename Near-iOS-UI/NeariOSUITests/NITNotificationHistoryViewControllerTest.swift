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
        historyVC.includeCoupons = true
        historyVC.includeFeedbacks = true
        historyVC.includeCustomJson = true
        
        historyVC.refreshHistory()
        
        let numberOfSections = historyVC.numberOfSections(in: historyVC.tableView)
        XCTAssertTrue(numberOfSections == 2)
    }
    
    func testAvailableItemsOnlyJSON() {
        mockManager.items = itemsJSONAndFeedback()
        historyVC.includeCustomJson = true
        historyVC.includeFeedbacks = false
        
        historyVC.refreshHistory()
        
        let numberOfSections = historyVC.numberOfSections(in: historyVC.tableView)
        XCTAssertTrue(numberOfSections == 1)
    }
    
    func testAvailableItemsOnlyFeedback() {
        mockManager.items = itemsJSONAndFeedback()
        historyVC.includeFeedbacks = true
        
        historyVC.refreshHistory()
        
        let numberOfSections = historyVC.numberOfSections(in: historyVC.tableView)
        XCTAssertTrue(numberOfSections == 1)
    }
    
    func testAvailableItemsNoJSONAndFeedback() {
        mockManager.items = itemsJSONAndFeedback()
        historyVC.includeCoupons = false
        historyVC.includeFeedbacks = false
        historyVC.includeCustomJson = false
        
        historyVC.refreshHistory()
        
        let numberOfSections = historyVC.numberOfSections(in: historyVC.tableView)
        XCTAssertTrue(numberOfSections == 0)
    }
    
    func itemsJSONAndFeedback() -> [NITHistoryItem] {
        let customJson = NITCustomJSON()
        let feedback = NITFeedback()
        
        let itemJson = NITHistoryItem()
        itemJson.reactionBundle = customJson
        let itemFeedback = NITHistoryItem()
        itemFeedback.reactionBundle = feedback
        
        return [itemJson, itemFeedback]
    }
}

class MockHistoryManager: NITManager {
    
    var items: [NITHistoryItem]?
    
    override func history(completion: @escaping ([NITHistoryItem]?, Error?) -> Void) {
        completion(items, nil)
    }
}
