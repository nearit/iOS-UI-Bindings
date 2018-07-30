//
//  NITMultilineButton.swift
//  NearUIBinding
//
//  Created by Cattaneo Stefano on 16/07/2018.
//  Copyright © 2018 Near. All rights reserved.
//

import UIKit

@IBDesignable
public class NITMultilineButton: UIButton {

    @IBOutlet var contentView: NITMultilineButton!
    
    @IBInspectable var leftImage: UIImage? {
        didSet { leftImageView.image = leftImage }
    }
    
    @IBInspectable public var rightImage: UIImage? {
        didSet { rightImageView.image = rightImage }
    }
    
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var rightImageView: UIImageView!
    
    @IBOutlet weak var firstLineLabel: UILabel!
    @IBOutlet weak var secondLineLabel: UILabel!
    
    @IBInspectable public var happyImage: UIImage?
    @IBInspectable public var worriedImage: UIImage?
    @IBInspectable public var sadImage: UIImage?
    private var defaultHappyImage: UIImage?
    private var defaultWorriedImage: UIImage?
    private var defaultSadImage: UIImage?
    
    private func getHappyImage() -> UIImage? {
        return happyImage ?? defaultHappyImage
    }
    
    private func getWorriedImage() -> UIImage? {
        return worriedImage ?? defaultWorriedImage
    }
    
    private func getSadImage() -> UIImage? {
        return sadImage ?? defaultSadImage
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        let bundle = Bundle.NITBundle(for: NITMultilineButton.self)
        bundle.loadNibNamed("NITMultilineButton", owner: self, options: nil)
        defaultSadImage = UIImage(named: "sad", in: Bundle.NITBundle(for: NITMultilineButton.self), compatibleWith: nil)
        defaultWorriedImage = UIImage(named: "worried", in: Bundle.NITBundle(for: NITMultilineButton.self), compatibleWith: nil)
        defaultHappyImage = UIImage(named: "happyGreen", in: Bundle.NITBundle(for: NITMultilineButton.self), compatibleWith: nil)
        
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        
        contentView.backgroundColor = NITUIAppearance.sharedInstance.nearBlack()
        contentView.layer.masksToBounds = true
        
        if let regularFontName = NITUIAppearance.sharedInstance.regularFontName {
            secondLineLabel.changeFont(to: regularFontName)
        }
        
        if let boldFontName = NITUIAppearance.sharedInstance.boldFontName {
            firstLineLabel.changeFont(to: boldFontName)
        }
        
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        let number = contentView.layer.frame.height / 2
        contentView.layer.cornerRadius = number
    }
    
    public func setLabel(_ firstLine: String, secondLine: String? = nil) {
        firstLineLabel.text = firstLine
        if let secondLine = secondLine {
            secondLineLabel.text = secondLine
            secondLineLabel.isHidden = false
        } else {
            secondLineLabel.isHidden = true
        }
    }
    
    public func setColor(_ color: UIColor) {
        contentView.backgroundColor = color
    }
    
    public func makeHappy() {
        rightImage = getHappyImage()
        secondLineLabel.textColor = NITUIAppearance.sharedInstance.nearBlack()
    }
    
    public func makeSad() {
        rightImage = getSadImage()
        secondLineLabel.textColor = NITUIAppearance.sharedInstance.nearRed()
    }
    
    public func makeWorried() {
        rightImage = getWorriedImage()
        secondLineLabel.textColor = UIColor.worriedYellow
    }

}
