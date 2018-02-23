//
//  NITInboxCell.swift
//  NearUIBinding
//
//  Created by francesco.leoni on 23/02/18.
//  Copyright © 2018 Near. All rights reserved.
//

import UIKit

class NITInboxCell: UITableViewCell {
    
    @IBOutlet weak var subContent: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
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
}
