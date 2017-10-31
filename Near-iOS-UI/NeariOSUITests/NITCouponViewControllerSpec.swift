//
//  NITCouponViewControllerSpec.swift
//  NeariOSUITests
//
//  Created by Nicola Ferruzzi on 31/10/2017.
//  Copyright © 2017 Near. All rights reserved.
//

import Quick
import Nimble
import FBSnapshotTestCase
import Nimble_Snapshots
@testable import NearITSDK
@testable import NeariOSUI

class NITCouponViewControllerSpec: QuickSpec {

    func createExpiredCoupon() -> NITCoupon {
        let coupon = NITCoupon()
        coupon.couponDescription = "Description"
        coupon.value = "10 $"
        coupon.expiresAt = "2017-06-05T08:32:00.000Z"
        coupon.redeemableFrom = "2017-06-01T08:32:00.000Z"
        let claim = NITClaim()
        claim.serialNumber = "0123456789"
        coupon.claims = [claim]
        coupon.icon = NITImage()
        coupon.icon.image = ["square_300": ["url": "https://avatars0.githubusercontent.com/u/18052069?s=200&v=4"]]
        return coupon
    }

    func createValidCoupon() -> NITCoupon {
        let coupon = NITCoupon()
        coupon.couponDescription = "Long coupon description, Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna ali."
        coupon.value = "Value qwertyuioplkjhgfdsazxcvbnmpoiuytrewqasdfghj!"
        coupon.expiresAt = "3017-06-05T08:32:00.000Z"
        let claim = NITClaim()
        claim.serialNumber = "0123456789"
        coupon.claims = [claim]
        coupon.icon = NITImage()
        return coupon
    }

    func createInactiveCoupon() -> NITCoupon {
        let coupon = NITCoupon()
        coupon.couponDescription = "Description"
        coupon.value = "10 $"
        coupon.redeemableFrom = "3017-06-05T08:32:00.000Z"
        let claim = NITClaim()
        claim.serialNumber = "0123456789"
        coupon.claims = [claim]
        coupon.icon = NITImage()
        return coupon
    }

    func decodeQRCode(image: CIImage?) -> String? {
        guard let image = image else { return nil }
        if let detector = CIDetector(ofType: CIDetectorTypeQRCode,
                                     context: nil,
                                     options: [CIDetectorAccuracy: "H"]) {
            let features = detector.features(in: image)
            for feature in features {
                if let f = feature as? CIQRCodeFeature {
                    return f.messageString
                }
            }
        }

        return nil
    }

    override func spec() {
        var couponVC: NITCouponViewController!
        let validCoupon = createValidCoupon()
        let expiredCoupon = createExpiredCoupon()
        let inactiveCoupon = createInactiveCoupon()

        describe("qrcode generation") {
            it("can generate proper qrcode, short test") {
                let coupon = NITCoupon()
                let claim = NITClaim()
                let serial = "123 456 789"
                claim.serialNumber = serial
                coupon.claims = [claim]

                let message = self.decodeQRCode(image: coupon.qrCodeImage)
                expect(serial).to(equal(message))
            }

            it("can generate proper qrcode, long test") {
                let coupon = NITCoupon()
                let claim = NITClaim()
                let serial = "Long coupon description, Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna ali."
                claim.serialNumber = serial
                coupon.claims = [claim]

                let message = self.decodeQRCode(image: coupon.qrCodeImage)
                expect(serial).to(equal(message))
            }

            it("nothing to generate here") {
                let coupon = NITCoupon()
                let message = self.decodeQRCode(image: coupon.qrCodeImage)
                expect(message).to(beNil())
            }
        }

        describe("valid") {
            beforeEach {
                couponVC = NITCouponViewController(coupon: validCoupon)
                expect(couponVC.view).notTo(beNil())
            }

            it("is valid if the current date is inside the reedemable/expiresAt range") {
                expect(couponVC.coupon.status).to(equal(NITCouponUIStatus.valid))
            }

            it("UI shows qrcode and serial, alternative text is hidden") {
                expect(couponVC.qrcode.isHidden).to(beFalse())
                expect(couponVC.serial.isHidden).to(beFalse())
                expect(couponVC.alternative.isHidden).to(beTrue())
                expect(couponVC.serial.text).to(equal(couponVC.coupon.qrCodeValue))
            }
        }

        describe("expired") {
            beforeEach {
                couponVC = NITCouponViewController(coupon: expiredCoupon)
                expect(couponVC.view).notTo(beNil())
            }

            it("is expired if the current date is ahead of expiresAt date") {
                expect(couponVC.coupon.status).to(equal(NITCouponUIStatus.expired))
            }

            it("the UI hides qrcode and serial, alternative text is visible") {
                expect(couponVC.qrcode.isHidden).to(beTrue())
                expect(couponVC.serial.isHidden).to(beTrue())
                expect(couponVC.alternative.isHidden).to(beFalse())
                expect(couponVC.alternative.text).to(equal(couponVC.expiredText))
            }
        }

        describe("disabled/inactive") {
            beforeEach {
                couponVC = NITCouponViewController(coupon: inactiveCoupon)
                expect(couponVC.view).notTo(beNil())
            }

            it("is disabled if the current date is before the redeemable date") {
                expect(couponVC.coupon.status).to(equal(NITCouponUIStatus.disabled))
            }

            it("the UI hides qrcode and serial, alternative text is visible") {
                expect(couponVC.qrcode.isHidden).to(beTrue())
                expect(couponVC.serial.isHidden).to(beTrue())
                expect(couponVC.alternative.isHidden).to(beFalse())
                expect(couponVC.alternative.text).to(equal(couponVC.disabledText))
            }
        }

    }
}
