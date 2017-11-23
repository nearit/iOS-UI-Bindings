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
    @objc public var couponValidColor = UIColor.nearCouponValid
    @objc public var couponDisabledColor = UIColor.nearCouponDisabled
    @objc public var couponExpiredColor = UIColor.nearCouponExpired
    @objc public var validFont = UIFont.systemFont(ofSize: 12.0)
    @objc public var fromToFont = UIFont.italicSystemFont(ofSize: 12.0)
    @objc public var alternativeFont = UIFont.systemFont(ofSize: 20.0)
    @objc public var titleFont = UIFont.systemFont(ofSize: 16.0)
    @objc public var titleColor = UIColor.nearBlack
    @objc public var descriptionFont = UIFont.systemFont(ofSize: 13.0)
    @objc public var descriptionColor = UIColor.nearWarmGrey
    @objc public var serialFont = UIFont.systemFont(ofSize: 20.0)
    @objc public var serialColor = UIColor.nearBlack
    @objc public var valueFont = UIFont.systemFont(ofSize: 20.0)
    @objc public var valueColor = UIColor.nearBlack

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
        hideCloseButton = true
        let dialog = NITDialogController(viewController: self)
        dialog.hidesBottomBarWhenPushed = true
        dialog.backgroundStyle = .plain
        dialog.backgroundColor = .nearPushedBackground
        dialog.contentPosition = .middle
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
        let validAttrs: [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.font: validFont,
            NSAttributedStringKey.foregroundColor: color
        ]

        let fromToAttrs: [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.font: fromToFont,
            NSAttributedStringKey.foregroundColor: UIColor.nearWarmGrey
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
        serial.font = serialFont
        serial.textColor = serialColor

        couponTitle.text = coupon.title ?? "Title"
        couponTitle.textColor = titleColor
        couponTitle.font = titleFont

        longDescription.text = coupon.couponDescription
        longDescription.font = descriptionFont
        longDescription.textColor = descriptionColor

        value.text = coupon.value
        value.font = valueFont
        value.textColor = valueColor

        separator.isHidden = !drawSeparator
        separator.image = separatorImage
        separator.backgroundColor = separatorBackgroundColor
        close.isHidden = hideCloseButton

        icon.image = iconPlaceholder

        alternative.font = alternativeFont

        if let iconURL = coupon.icon.smallSizeURL() {
            applyImage(fromURL: iconURL, toImageView: icon)
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
            alternative.textColor = couponDisabledColor
            value.textColor = couponDisabledColor
            longDescription.textColor = couponDisabledColor
            couponTitle.textColor = couponDisabledColor
            serial.isHidden = true
            setupDates(color: couponExpiredColor)
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

}
