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
    var closeCallback: ((NITCouponViewController) -> Void)?

    public var drawSeparator = true
    public var hideCloseButton = false
    public var separatorImage: UIImage!
    public var separatorBackgroundColor = UIColor.clear
    public var iconPlaceholder: UIImage!
    public var expiredText = NSLocalizedString("Expired coupon", comment: "Coupon dialog: expired coupon")
    public var disabledText = NSLocalizedString("Inactive coupon", comment: "Coupon dialog: inactive coupon")
    public var validText = NSLocalizedString("Valid:", comment: "Coupon dialog: valid: ")
    public var fromText = NSLocalizedString("from", comment: "Coupon dialog: from")
    public var toText = NSLocalizedString("to", comment: "Coupon dialog: to")
    public var couponValidColor = UIColor.nearCouponValid
    public var couponDisabledColor = UIColor.nearCouponDisabled
    public var couponExpiredColor = UIColor.nearCouponExpired
    public var validFont = UIFont.systemFont(ofSize: 12.0)
    public var fromToFont = UIFont.italicSystemFont(ofSize: 12.0)
    public var alternativeFont = UIFont.systemFont(ofSize: 20.0)
    public var titleFont = UIFont.systemFont(ofSize: 16.0)
    public var titleColor = UIColor.nearBlack
    public var descriptionFont = UIFont.systemFont(ofSize: 13.0)
    public var descriptionColor = UIColor.nearWarmGrey
    public var serialFont = UIFont.systemFont(ofSize: 20.0)
    public var serialColor = UIColor.nearBlack
    public var valueFont = UIFont.systemFont(ofSize: 20.0)
    public var valueColor = UIColor.nearBlack

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
    
    public init(coupon: NITCoupon, closeCallback: ((NITCouponViewController) -> Void)? = nil, manager: NITManager = NITManager.default()) {
        let bundle = Bundle(for: NITDialogController.self)
        self.closeCallback = closeCallback
        self.coupon = coupon
        self.nearManager = manager
        super.init(nibName: "NITCouponViewController", bundle: bundle)
        setupDefaultElements()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func show(configureDialog: ((_ dialogController: NITDialogController) -> ())? = nil ) {
        if let viewController = UIApplication.shared.keyWindow?.currentController() {
            self.show(fromViewController: viewController, configureDialog: configureDialog)
        }
    }

    public func show(fromViewController: UIViewController, configureDialog: ((_ dialogController: NITDialogController) -> ())? = nil) {
        let dialog = NITDialogController(viewController: self)
        if let configDlg = configureDialog {
            configDlg(dialog)
        }
        fromViewController.present(dialog, animated: true, completion: nil)
    }

    func setupDefaultElements() {
        let bundle = Bundle(for: NITDialogController.self)
        separatorImage = UIImage(named: "separator", in: bundle, compatibleWith: nil)
        iconPlaceholder = UIImage(named: "couponPlaceholder", in: bundle, compatibleWith: nil)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    internal func setupQRCode() {
        if let oimage = coupon.qrCodeImage {
            let scaleX = qrcode.frame.size.width / oimage.extent.size.width
            let scaleY = qrcode.frame.size.height / oimage.extent.size.height
            let affine = CGAffineTransform(scaleX: scaleX, y: scaleY)
            let transformedImage = oimage.applying(affine)
            qrcode.image = UIImage(ciImage: transformedImage)
        } else {
            qrcode.image = nil
        }
    }

    internal func setupDates(color: UIColor) {
        let validAttrs: [String: Any] = [
            NSFontAttributeName: validFont,
            NSForegroundColorAttributeName: color
        ]

        let fromToAttrs: [String: Any] = [
            NSFontAttributeName: fromToFont,
            NSForegroundColorAttributeName: UIColor.nearWarmGrey
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
            DispatchQueue.global(qos: .userInitiated).async {
                let data = try? Data(contentsOf: iconURL)
                if let imageData = data, let image = UIImage(data: imageData) {
                    DispatchQueue.main.async { [weak self] () -> Void in
                        self?.icon.image = image
                    }
                }
            }
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
        if let closeCallback = closeCallback {
            closeCallback(self)
        } else {
            dialogController?.dismiss()
        }
    }

}
