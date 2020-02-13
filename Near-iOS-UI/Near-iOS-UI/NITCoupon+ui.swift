//
//  NITCoupon+ui.swift
//  NeariOSUI
//
//  Created by Nicola Ferruzzi on 30/10/2017.
//  Copyright © 2017 Near. All rights reserved.
//

import NearITSDK

@objc public enum NITCouponUIStatus: NSInteger {
    case valid = 0
    case inactive
    case expired
    case redeemed
}

extension NITCoupon {
    var status: NITCouponUIStatus {
        if redeemedAt != nil {
            return .redeemed
        }
        
        if let redeemable = redeemable, redeemable.timeIntervalSinceNow > 0.0 {
            return .inactive
        }

        if let expires = expires, expires.timeIntervalSinceNow < 0.0 {
            return .expired
        }

        return .valid
    }

    var qrCodeValue: String? {
        return serial
    }

    var qrCodeImage: CIImage? {
        guard let value = qrCodeValue else { return nil }
        let data = value.data(using: .isoLatin1, allowLossyConversion: false)
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel")
        return filter.outputImage
    }

    var localizedRedeemable: String? {
        guard let date = redeemable else { return nil }
        let formatter = couponLocale()
        return formatter.string(from: date)
    }
    
    var localizedExpiredAt: String? {
        guard let date = expires else { return nil }
        let formatter = couponLocale()
        return formatter.string(from: date)
    }
    
    var localizedRedeemedAt: String? {
        guard let date = redeemed else { return nil }
        let formatter = couponLocale()
        return formatter.string(from: date)
    }
    
    func couponLocale() -> DateFormatter {
        if let couponFormatter = NITUIAppearance.sharedInstance.couponDateFormatter {
            return couponFormatter
        }
        let formatter = DateFormatter()
        formatter.locale = Locale.preferredLocale()
        formatter.dateFormat = "nearit_ui_coupon_date_pretty_format".nearUILocalized
        return formatter
    }

    var isRedeemed: Bool {
        return redeemedAt != nil
    }
}

extension Locale {
    static func preferredLocale() -> Locale {
        guard let preferredIdentifier = Locale.preferredLanguages.first else {
            return Locale.current
        }
        return Locale(identifier: preferredIdentifier)
    }
}
