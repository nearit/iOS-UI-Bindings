//
//  NITCouponViewController
//  NeariOSUI
//
//  Created by Nicola Ferruzzi on 16/10/2017.
//  Copyright © 2017 Near. All rights reserved.
//

import UIKit
import NearITSDK

public class NITCouponViewController: NITBaseViewController {
    var coupon: NITCoupon!
    var nearManager: NITManager
    var previousBrightness: CGFloat = 1.0
    var previousTimer: Bool = false

    @objc public var drawSeparator = true
    @objc public var hideCloseButton = false
    @objc public var separatorImage: UIImage!
    @objc public var separatorBackgroundColor = UIColor.clear
    @objc public var iconPlaceholder: UIImage!
    @objc public var expiredText: String!
    @objc public var disabledText: String!
    @objc public var validText: String!
    @objc public var fromText: String!
    @objc public var toText: String!
    @objc public var couponValidColor = NITUIAppearance.sharedInstance.nearGreen()
    @objc public var couponDisabledColor = NITUIAppearance.sharedInstance.nearGrey()
    @objc public var couponDisabledAlternativeColor = NITUIAppearance.sharedInstance.nearBlack()
    @objc public var couponExpiredColor = NITUIAppearance.sharedInstance.nearRed()
    
    let defaultValidFont = UIFont.systemFont(ofSize: 12.0)
    @objc public var validFont: UIFont?
    
    let defaultFromToFont = UIFont.italicSystemFont(ofSize: 12.0)
    @objc public var fromToFont: UIFont?
    
    let defaultAlternativeFont = UIFont.italicSystemFont(ofSize: 20.0)
    @objc public var alternativeFont: UIFont?
    
    let defaultTitleFont = UIFont.systemFont(ofSize: 16.0)
    @objc public var titleFont: UIFont?
    
    let defaultDescriptionFont = UIFont.systemFont(ofSize: 13.0)
    @objc public var descriptionFont: UIFont?
    
    let defaultSerialFont = UIFont.systemFont(ofSize: 20.0)
    @objc public var serialFont: UIFont?
    
    let defaultValueFont = UIFont.boldSystemFont(ofSize: 20.0)
    @objc public var valueFont: UIFont?
    
    
    @objc public var titleColor = NITUIAppearance.sharedInstance.nearBlack()
    @objc public var descriptionColor = NITUIAppearance.sharedInstance.nearGrey()
    @objc public var serialColor = NITUIAppearance.sharedInstance.nearBlack()
    @objc public var valueColor = NITUIAppearance.sharedInstance.nearBlack()

    @IBOutlet weak var dates: UILabel!
    @IBOutlet weak var qrcode: UIImageView!
    @IBOutlet weak var longDescription: UILabel!
    @IBOutlet weak var alternative: UILabel!
    @IBOutlet weak var separator: UIImageView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var serial: UILabel!
    @IBOutlet weak var couponTitle: UILabel!
    @IBOutlet weak var value: UILabel!
    @IBOutlet weak var close: UIButton!

    @objc public convenience init(coupon: NITCoupon) {
        self.init(coupon: coupon, manager: nil)
    }
    
    init(coupon: NITCoupon, manager: NITManager?) {
        let bundle = Bundle.NITBundle(for: NITDialogController.self)
        self.coupon = coupon
        self.nearManager = manager ?? NITManager.default()
        super.init(nibName: "NITCouponViewController", bundle: bundle)
        setupDefaultElements()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc public func show() {
        show(fromViewController: nil, configureDialog: nil)
    }

    @objc public func show(fromViewController: UIViewController?, configureDialog: ((_ dialogController: NITDialogController) -> ())?) {

        if let fromViewController = fromViewController ?? UIApplication.shared.keyWindow?.currentController() {

            let dialog = NITDialogController(viewController: self)
            if let configDlg = configureDialog {
                configDlg(dialog)
            }

            fromViewController.present(dialog, animated: true, completion: nil)
        }
    }
    
    @objc public func show(navigationController: UINavigationController) {
        show(navigationController: navigationController, title: nil)
    }

    @objc public func show(navigationController: UINavigationController, title: String? = nil) {
        hideCloseButton = true
        let dialog = NITDialogController(viewController: self)
        dialog.hidesBottomBarWhenPushed = true
        dialog.backgroundStyle = .plain
        dialog.backgroundColor = .nearPushedBackground
        dialog.contentPosition = .middle
        if let title = title {
            dialog.title = title
        }
        navigationController.pushViewController(dialog, animated: true)
    }

    func setupDefaultElements() {
        let bundle = Bundle.NITBundle(for: NITDialogController.self)
        separatorImage = UIImage(named: "separator", in: bundle, compatibleWith: nil)
        iconPlaceholder = UIImage(named: "couponPlaceholder", in: bundle, compatibleWith: nil)

        expiredText = NSLocalizedString("Coupon dialog: expired coupon", tableName: nil, bundle: bundle, value: "Expired coupon", comment: "Coupon dialog: expired coupon")
        disabledText = NSLocalizedString("Coupon dialog: inactive coupon", tableName: nil, bundle: bundle, value: "Inactive coupon", comment: "Coupon dialog: inactive coupon")
        validText = NSLocalizedString("Coupon dialog: valid:", tableName: nil, bundle: bundle, value: "Valid: ", comment: "Coupon dialog: valid:[whitespace]")
        fromText = NSLocalizedString("Coupon dialog: from", tableName: nil, bundle: bundle, value: "from", comment: "Coupon dialog: from")
        toText = NSLocalizedString("Coupon dialog: to", tableName: nil, bundle: bundle, value: "to", comment: "Coupon dialog: to")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        previousTimer = UIApplication.shared.isIdleTimerDisabled
        previousBrightness = UIScreen.main.brightness
        UIApplication.shared.isIdleTimerDisabled = true
        UIScreen.main.brightness = 1.0
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = previousTimer
        UIScreen.main.brightness = previousBrightness
    }

    internal func setupQRCode() {
        if let oimage = coupon.qrCodeImage {
            let scaleX = qrcode.frame.size.width / oimage.extent.size.width
            let scaleY = qrcode.frame.size.height / oimage.extent.size.height
            let affine = CGAffineTransform(scaleX: scaleX, y: scaleY)
            let transformedImage = oimage.transformed(by: affine)
            qrcode.image = UIImage(ciImage: transformedImage)
        } else {
            qrcode.image = nil
        }
    }

    internal func setupDates(color: UIColor) {
        let validAttrs: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: getValidFont(),
            NSAttributedString.Key.foregroundColor: color
        ]

        let fromToAttrs: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: getFromToFont(),
            NSAttributedString.Key.foregroundColor: NITUIAppearance.sharedInstance.nearGrey()
        ]

        let text = NSMutableAttributedString()
        text.append(NSAttributedString(string: validText, attributes: validAttrs))
        text.append(NSAttributedString(string: " ", attributes: validAttrs))

        if let _ = coupon.redeemable {
            text.append(NSAttributedString(string: fromText, attributes: fromToAttrs))
            text.append(NSAttributedString(string: " ", attributes: fromToAttrs))
            text.append(NSAttributedString(string: coupon.localizedRedeemable, attributes: fromToAttrs))
            text.append(NSAttributedString(string: " ", attributes: fromToAttrs))
        }

        if let _ = coupon.expires {
            text.append(NSAttributedString(string: toText, attributes: fromToAttrs))
            text.append(NSAttributedString(string: " ", attributes: fromToAttrs))
            text.append(NSAttributedString(string: coupon.localizedExpiredAt, attributes: fromToAttrs))
        }

        dates.attributedText = text
    }

    internal func setupUI() {
        dialogController?.contentView.backgroundColor = .clear

        setupQRCode()
        serial.text = coupon.qrCodeValue
        serial.font = getSerialFont()
        serial.textColor = serialColor

        couponTitle.text = coupon.title ?? "Title"
        couponTitle.textColor = titleColor
        couponTitle.font = getTitleFont()

        longDescription.text = coupon.couponDescription
        longDescription.font = getDescriptionFont()
        longDescription.textColor = descriptionColor

        value.text = coupon.value
        value.font = getValueFont()
        value.textColor = valueColor

        separator.isHidden = !drawSeparator
        separator.image = separatorImage
        separator.backgroundColor = separatorBackgroundColor
        close.isHidden = hideCloseButton

        icon.image = iconPlaceholder
        icon.layer.borderColor = UIColor.init(red: 51/255, green: 51/255, blue: 51/255, alpha: 1).cgColor
        icon.layer.borderWidth = 1.0

        alternative.font = getAlternativeFont()

        if let iconURL = coupon.icon?.smallSizeURL() {
            applyImage(fromURL: iconURL, toImageView: icon, imageDownloader: NITImageDownloader.sharedInstance)
        }

        switch coupon.status {
        case .valid:
            alternative.isHidden = true
            qrcode.isHidden = false
            alternative.textColor = couponValidColor
            serial.isHidden = false
            setupDates(color: couponValidColor)
        case .disabled:
            alternative.isHidden = false
            qrcode.isHidden = true
            alternative.text = disabledText
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
        }
    }

    @IBAction func tapClose(_ sender: Any) {
        dialogController?.dismiss()
    }
    
    private func getValidFont() -> UIFont {
        if let validFont = self.validFont {
            return validFont
        }
        if let globalItalic = NITUIAppearance.sharedInstance.italicFontName {
            return UIFont.init(name: globalItalic, size: defaultValidFont.pointSize) ?? defaultValidFont
        }
        return defaultValidFont
    }
    
    private func getFromToFont() -> UIFont {
        if let fromToFont = self.fromToFont {
            return fromToFont
        }
        if let globalItalic = NITUIAppearance.sharedInstance.italicFontName {
            return UIFont.init(name: globalItalic, size: defaultFromToFont.pointSize) ?? defaultFromToFont
        }
        return defaultFromToFont
    }
    
    private func getAlternativeFont() -> UIFont {
        if let alternativeFont = self.alternativeFont {
            return alternativeFont
        }
        if let globalItalic = NITUIAppearance.sharedInstance.italicFontName {
            return UIFont.init(name: globalItalic, size: defaultAlternativeFont.pointSize) ??
                defaultAlternativeFont
        }
        return defaultAlternativeFont
    }
    
    private func getTitleFont() -> UIFont {
        if let titleFont = self.titleFont {
            return titleFont
        }
        if let regularFont = NITUIAppearance.sharedInstance.regularFontName {
            return UIFont.init(name: regularFont, size: defaultTitleFont.pointSize) ??
                defaultTitleFont
        }
        return defaultTitleFont
    }
    
    private func getDescriptionFont() -> UIFont {
        if let descriptionFont = self.descriptionFont {
            return descriptionFont
        }
        if let regularFont = NITUIAppearance.sharedInstance.regularFontName {
            return UIFont.init(name: regularFont, size: defaultDescriptionFont.pointSize) ??
                defaultDescriptionFont
        }
        return defaultDescriptionFont
    }
    
    private func getSerialFont() -> UIFont {
        if let serialFont = self.serialFont {
            return serialFont
        }
        if let regularFont = NITUIAppearance.sharedInstance.regularFontName {
            return UIFont.init(name: regularFont, size: defaultSerialFont.pointSize) ??
                defaultSerialFont
        }
        return defaultSerialFont
    }
    
    private func getValueFont() -> UIFont {
        if let valueFont = self.valueFont {
            return valueFont
        }
        if let boldFont = NITUIAppearance.sharedInstance.boldFontName {
            return UIFont.init(name: boldFont, size: defaultValueFont.pointSize) ??
                defaultValueFont
        }
        return defaultValueFont
    }

}
