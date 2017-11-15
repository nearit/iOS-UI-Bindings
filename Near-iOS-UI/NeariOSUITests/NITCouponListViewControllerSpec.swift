//
//  NITCouponListViewControllerSpec.swift
//  NeariOSUITests
//
//  Created by Nicola Ferruzzi on 15/11/2017.
//  Copyright © 2017 Near. All rights reserved.
//

import Quick
import Nimble
import FBSnapshotTestCase
import Nimble_Snapshots
@testable import NearITSDK
@testable import NeariOSUI

class NITCouponListViewControllerSpec: NITCouponSpec {

    override func spec() {
        var couponListVC: NITCouponListViewController!
        var manager: FakeNearManager!

        describe("datasource") {
            beforeEach {
                manager = FakeNearManager()
                couponListVC = NITCouponListViewController(manager: manager)
            }

            afterEach {
                couponListVC.dialogController?.dismiss()
            }

            it("By default show all kind of coupons (valid, expired, disabled)") {
                let coupons = [
                    NITCouponSpec.createValidCoupon(),
                    NITCouponSpec.createExpiredCoupon(),
                    NITCouponSpec.createInactiveCoupon()
                ]

                manager.coupons = coupons
                couponListVC.show()
                expect(couponListVC.view).notTo(beNil())

                expect(manager.isEventCalled).toEventually(beTrue())
                expect(couponListVC.tableView.numberOfSections).to(equal(3))

                let validCell = couponListVC.tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as? NITCouponCell
                expect(validCell).notTo(beNil())
                expect(validCell?.value.text).to(equal(coupons[0].value))
                expect(validCell?.status.text).to(equal(couponListVC.validText))

                let expiredCell = couponListVC.tableView.cellForRow(at: IndexPath(item: 0, section: 1)) as? NITCouponCell
                expect(expiredCell).notTo(beNil())
                expect(expiredCell?.value.text).to(equal(coupons[1].value))
                expect(expiredCell?.status.text).to(equal(couponListVC.expiredText))

                let disabledCell = couponListVC.tableView.cellForRow(at: IndexPath(item: 0, section: 2)) as? NITCouponCell
                expect(disabledCell).notTo(beNil())
                expect(disabledCell?.value.text).to(equal(coupons[1].value))
                expect(disabledCell?.status.text).to(equal(couponListVC.disabledText))
            }

            it("Filter valid") {
                let coupons = [
                    NITCouponSpec.createExpiredCoupon(),
                    NITCouponSpec.createInactiveCoupon(),
                    NITCouponSpec.createValidCoupon(),
                ]

                manager.coupons = coupons

                couponListVC.filterOption = .valid
                couponListVC.show()
                expect(couponListVC.view).notTo(beNil())

                expect(manager.isEventCalled).toEventually(beTrue())
                expect(couponListVC.tableView.numberOfSections).to(equal(1))

                let cell = couponListVC.tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as? NITCouponCell
                expect(cell).notTo(beNil())
                expect(cell?.value.text).to(equal(coupons[2].value))
                expect(cell?.status.text).to(equal(couponListVC.validText))
            }

            it("Filter expired") {
                let coupons = [
                    NITCouponSpec.createInactiveCoupon(),
                    NITCouponSpec.createExpiredCoupon(),
                    NITCouponSpec.createValidCoupon(),
                ]

                manager.coupons = coupons

                couponListVC.filterOption = .expired
                couponListVC.show()
                expect(couponListVC.view).notTo(beNil())

                expect(manager.isEventCalled).toEventually(beTrue())
                expect(couponListVC.tableView.numberOfSections).to(equal(1))

                let cell = couponListVC.tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as? NITCouponCell
                expect(cell).notTo(beNil())
                expect(cell?.value.text).to(equal(coupons[1].value))
                expect(cell?.status.text).to(equal(couponListVC.expiredText))
            }

            it("Filter disabled") {
                let coupons = [
                    NITCouponSpec.createInactiveCoupon(),
                    NITCouponSpec.createExpiredCoupon(),
                    NITCouponSpec.createValidCoupon(),
                ]

                manager.coupons = coupons

                couponListVC.filterOption = .disabled
                couponListVC.show()
                expect(couponListVC.view).notTo(beNil())

                expect(manager.isEventCalled).toEventually(beTrue())
                expect(couponListVC.tableView.numberOfSections).to(equal(1))

                let cell = couponListVC.tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as? NITCouponCell
                expect(cell).notTo(beNil())
                expect(cell?.value.text).to(equal(coupons[0].value))
                expect(cell?.status.text).to(equal(couponListVC.disabledText))
            }

            it("Empty") {
                manager.coupons = []

                couponListVC.show()
                expect(couponListVC.view).notTo(beNil())

                expect(manager.isEventCalled).toEventually(beTrue())
                expect(couponListVC.tableView.numberOfSections).to(equal(1))

                let cell = couponListVC.tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as? NITCouponCell
                expect(cell).notTo(beNil())
                expect(cell?.subContent.isHidden).to(beTrue())
                expect(cell?.message.isHidden).to(beFalse())
                expect(cell?.message.text).to(equal(couponListVC.noCoupons))
            }

            it("Nil") {
                manager.coupons = nil

                couponListVC.show()
                expect(couponListVC.view).notTo(beNil())

                expect(manager.isEventCalled).toEventually(beTrue())
                expect(couponListVC.tableView.numberOfSections).to(equal(1))

                let cell = couponListVC.tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as? NITCouponCell
                expect(cell).notTo(beNil())
                expect(cell?.subContent.isHidden).to(beTrue())
                expect(cell?.message.isHidden).to(beFalse())
                expect(cell?.message.text).to(equal(couponListVC.noCoupons))
            }

            it("Retry in case of error") {
                manager.fakeSendEventError = true

                couponListVC.show()
                expect(couponListVC.view).notTo(beNil())

                expect(manager.isEventCalled).toEventually(beTrue())
                expect(couponListVC.tableView.numberOfSections).to(equal(1))

                let cell = couponListVC.tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as? NITCouponCell
                expect(cell).notTo(beNil())
                expect(cell?.subContent.isHidden).to(beTrue())
                expect(cell?.message.isHidden).to(beTrue())
                expect(cell?.loader.isHidden).to(beFalse())
            }
        }
    }

    fileprivate class FakeNearManager: NITManager {

        var fakeSendEventError = false
        var isEventCalled = false
        var coupons: [NITCoupon]?

        override func coupons(completionHandler handler: (([NITCoupon]?, Error?) -> Void)? = nil) {
            if (fakeSendEventError) {
                handler?(nil, FakeManagerError.sendEventError)
            } else {
                handler?(coupons, nil)
            }
            isEventCalled = true
        }
    }
}
