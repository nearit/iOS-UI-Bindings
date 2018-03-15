//
//  NITInboxCell.swift
//  NearUIBinding
//
//  Created by francesco.leoni on 23/02/18.
//  Copyright © 2018 Near. All rights reserved.
//

import UIKit

enum NITInboxCellState: Int {
    case read
    case unread
    case notReadable
}

class NITInboxCell: UITableViewCell {
    
    @IBOutlet weak var subContent: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var moreLabel: UILabel!
    @IBOutlet weak var moreIcon: UIImageView!
    var shadowOpacity: Float = 0.35
    var state: NITInboxCellState = .unread {
        didSet {
            changeStateUI()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        clipsToBounds = false
        contentView.layer.cornerRadius = 5
        contentView.layer.borderColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 0.5).cgColor
        contentView.layer.borderWidth = 1.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func makeBoldMessage(_ bold: Bool) {
        if bold {
            messageLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        } else {
            messageLabel.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        }
    }
    
    func makeBoldMore(_ bold: Bool) {
        if bold {
            moreLabel.font = UIFont.systemFont(ofSize: moreLabel.font.pointSize, weight: .bold)
        } else {
            moreLabel.font = UIFont.systemFont(ofSize: moreLabel.font.pointSize, weight: .regular)
        }
    }
    
    func makeShadow(_ shadow: Bool) {
        if shadow {
            contentView.layer.shadowOffset = CGSize(width: 0, height: 1);
            contentView.layer.shadowColor = UIColor.black.cgColor
            contentView.layer.shadowRadius = 5;
            contentView.layer.shadowOpacity = shadowOpacity;
        } else {
            contentView.layer.shadowOpacity = 0;
        }
    }
    
    func showMore(_ show: Bool = true) {
        moreLabel.isHidden = !show
        moreIcon.isHidden = !show
    }
    
    func changeStateUI() {
        switch state {
        case .read:
            selectionStyle = .default
            makeBoldMessage(false)
            makeBoldMore(false)
            shadowOpacity = 0.15
            makeShadow(true)
            showMore()
        case .unread:
            selectionStyle = .default
            makeBoldMessage(true)
            makeBoldMore(true)
            shadowOpacity = 0.35
            makeShadow(true)
            showMore()
        case .notReadable:
            selectionStyle = .none
            makeBoldMessage(false)
            makeBoldMore(false)
            makeShadow(false)
            showMore(false)
        }
    }
}
