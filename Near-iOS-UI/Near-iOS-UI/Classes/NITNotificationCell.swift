//
//  NITNotificationCell.swift
//  NearUIBinding
//
//  Created by francesco.leoni on 23/02/18.
//  Copyright © 2018 Near. All rights reserved.
//

import UIKit
import NearITSDK

enum NITNotificationCellState: Int {
    case read
    case unread
    case notReadable
}

class NITNotificationCell: UITableViewCell {
    
    @IBOutlet weak var subContent: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var moreLabel: UILabel!
    @IBOutlet weak var moreIcon: UIImageView!
    var unreadColor = UIColor(red: 119.0/255.0, green: 119.0/255.0, blue: 119.0/255.0, alpha: 1.0)
    var readColor = NITUIAppearance.sharedInstance.nearGrey()
    var dateColor = NITUIAppearance.sharedInstance.nearGrey()
    var messageColor = NITUIAppearance.sharedInstance.nearBlack()
    private var cardBackgroundReadColor = UIColor(red: 239.0/255.0, green: 239.0/255.0, blue: 239.0/255.0, alpha: 1.0)
    var shadowOpacity: Float = 0.15
    var dateFormatter: DateFormatter = NITNotificationHistoryViewController.historyDateFormatter()
    var state: NITNotificationCellState = .unread {
        didSet {
            changeStateUI()
        }
    }
    
    var item: NITHistoryItem? {
        didSet {
            guard let item = item else { return }
            bindTo(item)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        clipsToBounds = false
        contentView.layer.cornerRadius = 5
        let bundle = Bundle.NITBundle(for: NITNotificationCell.self)
        let icon = UIImage(named: "scopriBold", in: bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        moreIcon.image = icon?.imageFlippedForRightToLeftLayoutDirection()
        
        messageLabel.textColor = messageColor
        dateLabel.textColor = dateColor
    }
    
    func bindTo(_ item: NITHistoryItem) {
        backgroundColor = .clear
        let date = Date(timeIntervalSince1970: item.timestamp)
        dateLabel.text = dateFormatter.string(from: date)
        messageLabel.text = item.reactionBundle.notificationMessage
        if let _ = item.reactionBundle as? NITSimpleNotification {
            state = .notReadable
        } else {
            if item.read {
                state = .read
            } else {
                state = .unread
            }
        }
        setSeeMoreLabel(item)
    }
    
    func setSeeMoreLabel(_ item: NITHistoryItem) {
        switch item.reactionBundle {
        case _ as NITContent:
            moreLabel.text = "nearit_ui_history_content_button_label".nearUILocalized
        case _ as NITFeedback:
            moreLabel.text = "nearit_ui_history_feedback_button_label".nearUILocalized
        case _ as NITCoupon:
            moreLabel.text = "nearit_ui_history_coupon_button_label".nearUILocalized
        default:
            moreLabel.text = ""
        }
    }
    
    private func getBoldFont(size: CGFloat) -> UIFont {
        if let boldFont = NITUIAppearance.sharedInstance.boldFontName {
            return UIFont.init(name: boldFont, size: size) ?? UIFont.boldSystemFont(ofSize: size)
        }
        return UIFont.boldSystemFont(ofSize: size)
    }
    
    private func getRegularFont(size: CGFloat) -> UIFont {
        if let regularFont = NITUIAppearance.sharedInstance.regularFontName {
            return UIFont.init(name: regularFont, size: size) ?? UIFont.systemFont(ofSize: size)
        }
        return UIFont.systemFont(ofSize: size)
    }

    func makeBoldMessage(_ bold: Bool) {
        if bold {
            messageLabel.font = getBoldFont(size: messageLabel.font.pointSize)
        } else {
            messageLabel.font = getRegularFont(size: messageLabel.font.pointSize)
        }
    }
    
    func makeBoldMore(_ bold: Bool) {
        if bold {
            moreLabel.font = getBoldFont(size: moreLabel.font.pointSize)
        } else {
            moreLabel.font = getRegularFont(size: moreLabel.font.pointSize)
        }
    }
    
    func makeBoldDate(_ bold: Bool) {
        if bold {
            dateLabel.font = getBoldFont(size: dateLabel.font.pointSize)
        } else {
            dateLabel.font = getRegularFont(size: dateLabel.font.pointSize)
        }
    }
    
    func makeShadow(_ shadow: Bool) {
        if shadow {
            contentView.layer.shadowOffset = CGSize(width: 0, height: 1)
            contentView.layer.shadowColor = UIColor.black.cgColor
            contentView.layer.shadowRadius = 5
            contentView.layer.shadowOpacity = shadowOpacity
        } else {
            contentView.layer.shadowOpacity = 0
        }
    }
    
    func showMore(_ show: Bool = true) {
        moreLabel.isHidden = !show
        moreIcon.isHidden = !show
    }
    
    func setLabelsColor(_ color: UIColor) {
        moreLabel.textColor = color
        moreIcon.tintColor = unreadColor
    }
    
    func changeStateUI() {
        switch state {
        case .read:
            selectionStyle = .none
            makeBoldMessage(false)
            makeBoldMore(false)
            makeBoldDate(false)
            shadowOpacity = 0.15
            makeShadow(true)
            showMore()
            setLabelsColor(readColor)
            contentView.backgroundColor = cardBackgroundReadColor
        case .unread:
            selectionStyle = .none
            makeBoldMessage(true)
            makeBoldMore(true)
            makeBoldDate(true)
            shadowOpacity = 0.15
            makeShadow(true)
            showMore()
            setLabelsColor(unreadColor)
            contentView.backgroundColor = UIColor.white
        case .notReadable:
            selectionStyle = .none
            makeBoldMessage(false)
            makeBoldMore(false)
            makeBoldDate(false)
            makeShadow(false)
            showMore(false)
            setLabelsColor(readColor)
            contentView.backgroundColor = cardBackgroundReadColor
        }
    }
}
