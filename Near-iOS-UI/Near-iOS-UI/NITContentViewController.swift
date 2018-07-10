//
//  NITContentViewController
//  NeariOSUI
//
//  Created by Nicola Ferruzzi on 31/10/2017.
//  Copyright © 2017 Near. All rights reserved.
//

import UIKit
import NearITSDK
import SafariServices
import WebKit

public class NITContentViewController: NITBaseViewController {
    var content: NITContent!
    var trackingInfo: NITTrackingInfo?
    var nearManager: NITManager

    @objc public var linkHandler: ((NITContentViewController, URLRequest) -> WKNavigationActionPolicy)?
    @objc public var callToActionHandler: ((NITContentViewController, URL) -> Void)?
    @objc public var drawSeparator = true
    @objc public var hideCloseButton = false
    @objc public var imagePlaceholder: UIImage?
    @objc public var titleColor = UIColor.nearBlack
    @objc public var callToActionButton: UIImage!
    
    let defaultTitleFont = UIFont.boldSystemFont(ofSize: 20.0)
    @objc public var titleFont: UIFont?
    
    let defaultCTAFont = UIFont.boldSystemFont(ofSize: 18.0)
    @objc public var ctaFont: UIFont?
    
    @IBOutlet weak var close: UIButton!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var contentTitle: UILabel!
    @IBOutlet weak var titleContainer: UIView!
    @IBOutlet weak var webviewContainer: NITWKWebViewContainer!
    @IBOutlet weak var stackviewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackview: UIStackView!
    @IBOutlet weak var callToAction: UIButton!
    @IBOutlet weak var ctaContainer: UIView!
    @IBOutlet weak var topMarginContainer: UIView!
    @IBOutlet weak var closeContainer: UIView!

    @IBOutlet var constantConstraints: [NSLayoutConstraint]!

    @objc public convenience init(content: NITContent, trackingInfo: NITTrackingInfo? = nil) {
      self.init(content: content, trackingInfo: trackingInfo, manager: NITManager.default())
    }

    init(content: NITContent, trackingInfo : NITTrackingInfo?, manager: NITManager?) {
        let bundle = Bundle.NITBundle(for: NITDialogController.self)
        self.content = content
        self.trackingInfo = trackingInfo
        self.nearManager = manager ?? NITManager.default()
        super.init(nibName: "NITContentViewController", bundle: bundle)
        setupDefaultElements()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc public func show() {
        show(fromViewController: nil, configureDialog: nil)
    }

    @objc public func show(fromViewController: UIViewController?,
                     configureDialog: ((_ dialogController: NITDialogController) -> ())?) {
        if let fromViewController = fromViewController ?? UIApplication.shared.keyWindow?.currentController() {

            let dialog = NITDialogController(viewController: self)
            dialog.contentWidth = .container
            if let configureDialog = configureDialog {
                configureDialog(dialog)
            }

            fromViewController.present(dialog, animated: true, completion: nil)
        }
    }

    @objc public func show(navigationController: UINavigationController) {
        hideCloseButton = true
        let dialog = NITDialogController(viewController: self)
        dialog.hidesBottomBarWhenPushed = true
        dialog.backgroundStyle = .plain
        dialog.backgroundColor = .white
        dialog.contentPosition = .full
        navigationController.pushViewController(dialog, animated: true)
    }

    func setupDefaultElements() {
        let bundle = Bundle.NITBundle(for: NITDialogController.self)
        let filledOutline = UIImage(named: "filledButton", in: bundle, compatibleWith: nil)
        callToActionButton = filledOutline?.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 45, bottom: 0, right: 45))
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    internal func getImage() -> NITImage? {
        if content.image != nil { return content.image }
        guard let images = content.images else { return nil }
        return images.first
    }

    internal func setupUI() {
        if let dialogController = dialogController {
            dialogController.contentView.backgroundColor = .clear
            if dialogController.contentPosition == .full {
                constantConstraints.forEach({ (constraint) in
                    let constant = constraint.constant
                    constraint.constant = constant - 10
                })
            }
        }

        closeContainer.isHidden = hideCloseButton
        topMarginContainer.isHidden = !hideCloseButton

        if let placeholder = imagePlaceholder {
            image.image = placeholder
            imageContainer.isHidden = false
        } else {
            image.image = nil
            imageContainer.isHidden = true
        }
        
        if let contentImage = getImage(),
            let url = contentImage.url() ?? contentImage.smallSizeURL() {
            applyImage(fromURL: url, toImageView: image)
            imageContainer.isHidden = false
        }

        contentTitle.textColor = titleColor
        contentTitle.font = getTitleFont()
        contentTitle.text = content.title

        webviewContainer.linkHandler = { [weak self](request) in
            if let wself = self, let url = request.url {
                if let lh = wself.linkHandler {
                    return lh(wself, request)
                }
                let s = SFSafariViewController(url: url)
                wself.present(s, animated: true, completion: nil)
                return .cancel
            }
            return .allow
        }

        webviewContainer.loadContent(content: content)

        if let contentLink = content.link {
            callToAction.setTitle(contentLink.label, for: .normal)
            callToAction.setBackgroundImage(callToActionButton, for: .normal)
            callToAction.titleLabel?.font = getCTAFont()
        } else {
            ctaContainer.isHidden = true
        }
    }

    @IBAction func tapClose(_ sender: Any) {
        dialogController?.dismiss()
    }

    @IBAction func tapCallToAction(_ sender: Any) {
        if let trackingInfo = trackingInfo {
          nearManager.sendTracking(with: trackingInfo, event: NITRecipeCtaTapped)
        }
        if let ctaHandler = callToActionHandler {
            ctaHandler(self, content.link!.url)
        } else {
            let s = SFSafariViewController(url: content.link!.url)
            present(s, animated: true, completion: nil)
        }
    }
    
    private func getCTAFont() -> UIFont {
        if let ctaFont = self.ctaFont {
            return ctaFont
        }
        if let boldFont = NITUIAppearance.sharedInstance.boldFontName {
            return UIFont.init(name: boldFont, size: defaultCTAFont.pointSize) ?? defaultCTAFont
        }
        return defaultCTAFont
    }
    
    private func getTitleFont() -> UIFont {
        if let titleFont = self.titleFont {
            return titleFont
        }
        if let boldFont = NITUIAppearance.sharedInstance.boldFontName {
            return UIFont.init(name: boldFont, size: defaultTitleFont.pointSize) ?? defaultTitleFont
        }
        return defaultTitleFont
    }
}
