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
        bundle.loadNibNamed("SITMultilineButton", owner: self, options: nil)
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        
        contentView.backgroundColor = UIColor.charcoalGray
        contentView.layer.masksToBounds = true
        
        
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
        let happy = UIImage(named: "happyGreen", in: Bundle.NITBundle(for: NITMultilineButton.self), compatibleWith: nil)
        rightImage = happy
        leftImage = #imageLiteral(resourceName: "charcoalTick")
        firstLineLabel.textColor = UIColor.charcoalGray
        secondLineLabel.textColor = UIColor.charcoalGray
        setColor(UIColor.gray242)
    }
    
    public func makeSad() {
        let sad = UIImage(named: "sad", in: Bundle.NITBundle(for: NITMultilineButton.self), compatibleWith: nil)
        rightImage = sad
        secondLineLabel.textColor = UIColor.sadRed
    }
    
    public func makeWorried() {
        let worried = UIImage(named: "worried", in: Bundle.NITBundle(for: NITMultilineButton.self), compatibleWith: nil)
        rightImage = worried
        secondLineLabel.textColor = UIColor.worriedYellow
    }

}
