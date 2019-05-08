//
//  NearITUI.swift
//  NearUIBinding
//
//  Created by Cattaneo Stefano on 08/05/2019.
//  Copyright © 2019 Near. All rights reserved.
//

import Foundation
import NearITSDK
import UserNotifications

public class NearUIBinding {
    
    @available(iOS 10.0, *)
    static func showContentFrom(_ response: UNNotificationResponse,
                                completion: @escaping (NITReactionBundle?, NITTrackingInfo?, Error?) -> Void) {
        NITManager.default().processRecipe(with: response) { (content, trackingInfo, error) in
            if error != nil {
                completion(nil, nil, error)
                return
            }
            
            if let content = content as? NITContent {
                let contentVC = NITContentViewController(content: content)
                contentVC.show()
                completion(content, trackingInfo, nil)
            } else if let feedback = content as? NITFeedback {
                let feedbackVC = NITFeedbackViewController(feedback: feedback)
                feedbackVC.show()
                completion(feedback, trackingInfo, nil)
            } else if let coupon = content as? NITCoupon {
                let couponVC = NITCouponViewController(coupon: coupon)
                couponVC.show()
                completion(coupon, trackingInfo, nil)
            } else if let simple = content as? NITSimpleNotification {
                // there's no content attached to the system notification that was just pressed
                completion(simple, trackingInfo, nil)
            } else if let customJson = content as? NITCustomJSON {
                // handle your custom json
                completion(customJson, trackingInfo, nil)
            }
        }
    }
    
}
