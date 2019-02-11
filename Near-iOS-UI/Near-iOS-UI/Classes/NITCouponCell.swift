//
//  NITCouponCell.swift
//  NeariOSUI
//
//  Created by Nicola Ferruzzi on 13/11/2017.
//  Copyright © 2017 Near. All rights reserved.
//

import UIKit

class NITCouponCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var value: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var subContent: UIView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var message: UILabel!

    var url: URL!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        prepareForReuse()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        icon.layer.borderColor = UIColor.nearGrey.cgColor
        icon.layer.borderWidth = 1.0
        
        selectionStyle = .default
        loader.isHidden = true
        subContent.isHidden = false
        message.isHidden = true
    }

    func setLoading() {
        selectionStyle = .none
        loader.isHidden = false
        subContent.isHidden = true
        message.isHidden = true
    }

    func setMessage(_ text: String, color: UIColor, font: UIFont) {
        selectionStyle = .none
        loader.isHidden = true
        subContent.isHidden = true
        message.isHidden = false
        message.text = text
        message.textColor = color
        message.font = font
    }

    func applyImage(fromURL: URL!, imageDownloader: NITImageDownloader) {
        url = fromURL
        
        imageDownloader.downloadImageWithUrl(url: url) { (success, image, resultUrl) in
            if success {
                if self.url.absoluteString == resultUrl.absoluteString {
                    self.icon.image = image
                }
            }
        }
    }
}
