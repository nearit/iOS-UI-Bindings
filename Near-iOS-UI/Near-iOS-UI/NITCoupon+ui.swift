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
    case disabled
    case expired
}

extension NITCoupon {
    var status: NITCouponUIStatus {
        if let r = redeemable, r.timeIntervalSinceNow > 0.0 {
            return .disabled
        }

        if let e = expires, e.timeIntervalSinceNow < 0.0 {
            return .expired
        }

        return .valid
    }

    var qrCodeValue: String? {
        guard let claims = claims else { return nil }
        guard let claim = claims.first else { return nil }
        return claim.serialNumber
    }

    var qrCodeImage: CIImage? {
        guard let value = qrCodeValue else { return nil }
        let data = value.data(using: .isoLatin1, allowLossyConversion: false)
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel")
        return filter.outputImage
    }

    var localizedRedeemable: String {
        guard let date = redeemable else { return "" }
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = DateFormatter.Style.medium
        formatter.timeStyle = DateFormatter.Style.none
        return formatter.string(from: date)
    }

    var localizedExpiredAt: String {
        guard let date = expires else { return "" }
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = DateFormatter.Style.medium
        formatter.timeStyle = DateFormatter.Style.none
        return formatter.string(from: date)
    }

    var isRedeemed: Bool {
        for claim in claims {
            if claim.redeemedAt != nil {
                return true
            }
        }
        return false
    }
}
