//
//  NITCouponViewController+UI.swift
//  NearUIBinding
//
//  Created by Cattaneo Stefano on 12/02/2020.
//  Copyright © 2020 Near. All rights reserved.
//

import UIKit

extension NITCouponViewController {
    
    func setUpTopSection() {
        alternative.font = getAlternativeFont()
        
        switch coupon.status {
        case .valid:
            alternative.isHidden = true
            qrcode.isHidden = false
            serial.isHidden = false
            setupDates(color: couponValidColor)
        case .inactive:
            alternative.isHidden = false
            qrcode.isHidden = true
            alternative.text = inactiveText
            alternative.textColor = couponDisabledAlternativeColor
            value.textColor = couponDisabledColor.withAlphaComponent(0.35)
            longDescription.textColor = couponDisabledColor.withAlphaComponent(0.35)
            couponTitle.textColor = couponDisabledColor.withAlphaComponent(0.35)
            serial.isHidden = true
            setupDates(color: couponDisabledColor)
        case .expired:
            alternative.isHidden = false
            qrcode.isHidden = true
            alternative.text = expiredText
            alternative.textColor = couponExpiredColor
            serial.isHidden = true
            setupDates(color: couponExpiredColor)
        case .redeemed:
            alternative.isHidden = false
            qrcode.isHidden = true
            alternative.text = alreadyRedeemedText
            alternative.textColor = couponRedeemedColor
            serial.isHidden = true
            setupDates(color: couponRedeemedColor)
        }
    }
    
    internal func setupDates(color: UIColor) {
        validityLabel.font = getValidFont()
        validityFromLabel.font = getFromToFont()
        validityFromLabel.textColor = NITUIAppearance.sharedInstance.nearGrey()
        validityLabel.textColor = color
        validityLabel.text = validText + " "
        switch coupon.status {
        case .valid, .expired, .inactive:
            validityLabel.text = validText
            if let redeemable = coupon.localizedRedeemable,
                let expires = coupon.localizedExpiredAt {
                validityFromLabel.text = String(format: fromToText, redeemable, expires)
            } else if let expires = coupon.localizedExpiredAt {
                validityFromLabel.text = String(format: toText, expires)
            } else if let redeemable = coupon.localizedRedeemable {
                validityFromLabel.text = String(format: fromText, redeemable)
            } else {
                validityLabel.text = validNoPeriodText
            }
        case .redeemed:
            if let redeemedAt = coupon.localizedRedeemedAt {
                validityLabel.text = validityRedeemedText
                validityFromLabel.text = redeemedAt
            } else {
                validityLabel.text = ""
                validityFromLabel.text = ""
            }
        }
    }
}
