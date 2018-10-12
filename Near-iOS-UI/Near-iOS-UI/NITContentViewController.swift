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
    @objc public var titleColor = NITUIAppearance.sharedInstance.nearBlack()
    @objc public var htmlColor = NITUIAppearance.sharedInstance.nearBlack()
    @objc public var openLinksInWebView = false
    @objc public var webViewBarColor: UIColor?
    @objc public var webViewControlColor: UIColor?

    @objc public var callToActionColor: UIColor = NITUIAppearance.sharedInstance.nearBlack()
    @objc public var callToActionTextColor = NITUIAppearance.sharedInstance.nearWhite()
    
    let defaultTitleFont = UIFont.boldSystemFont(ofSize: 30.0)
    @objc public var titleFont: UIFont?
    
    let defaultCTAFont = UIFont.boldSystemFont(ofSize: 18.0)
    @objc public var ctaFont: UIFont?
    
    let defaultHTMLFont = UIFont.init(name: "Helvetica", size: 15.0) ?? UIFont.systemFont(ofSize: 15.0)
    @objc public var htmlFont: UIFont?
    
    @IBOutlet weak var close: UIButton!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var contentTitle: UILabel!
    @IBOutlet weak var titleContainer: UIView!
    @IBOutlet weak var stackviewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var htmlContent: UITextView!
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
        show(navigationController: navigationController, title: nil)
    }

    @objc public func show(navigationController: UINavigationController, title: String? = nil) {
        hideCloseButton = true
        let dialog = NITDialogController(viewController: self)
        dialog.hidesBottomBarWhenPushed = true
        dialog.backgroundStyle = .plain
        dialog.backgroundColor = .white
        dialog.contentPosition = .full
        if let title = title {
            dialog.title = title
        }
        navigationController.pushViewController(dialog, animated: true)
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
            applyImage(fromURL: url, toImageView: image, completionHandler: {(_) in
                self.fixImageView()
            })
            imageContainer.isHidden = false
        }

        contentTitle.textColor = titleColor
        contentTitle.font = getTitleFont()
        contentTitle.text = content.title
        
        if let htmlContent = content.content {
            loadHtmlContent(content: htmlContent)
        }
    
        if let contentLink = content.link {
            callToAction.setTitle(contentLink.label, for: .normal)
            callToAction.titleLabel?.font = getCTAFont()
            callToAction.setTitleColor(callToActionTextColor, for: .normal)
            callToAction.setRoundedButtonOf(color: callToActionColor)
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
            self.openUrl(url: content.link?.url)
        }
    }
    
    private func fixImageView() {
        if let image = self.image.image {
            if self.image.frame.size.width < image.size.width {
                self.imageHeightConstraint?.constant = self.image.frame.size.width / image.size.width * image.size.height
            }
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
    
    private func loadHtmlContent(content: String) {
        do{
            var bodiedContent = "<body>"
            bodiedContent.append(content)
            bodiedContent.append("</body><style>body {font-family: \(getFontName()); font-size: 16px;}</style>")
            
            let attrStr = try NSAttributedString(
                data: bodiedContent.data(using: String.Encoding.unicode, allowLossyConversion: true)!,
                options: [ .documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue],
                documentAttributes: nil)
            htmlContent.attributedText = attrStr
            htmlContent.textColor = htmlColor
            htmlContent.delegate = self
        } catch _ {
            print("error while formatting html")
        }
    }
    
    private func getHTMLFont() -> UIFont {
        if let htmlFont = htmlFont {
            return htmlFont
        }
        
        if let regularFontName = NITUIAppearance.sharedInstance.regularFontName {
            return UIFont.init(name: regularFontName, size: 16.0) ?? defaultHTMLFont
        }
        return defaultHTMLFont
    }
    
    private func getFontName() -> String {
        guard let regularFontName = NITUIAppearance.sharedInstance.regularFontName else {
            return "Helvetica"
        }
        return regularFontName
    }
    
    private func openUrl(url: URL?) {
        guard let link = url else { return }
        if (UIApplication.shared.canOpenURL(link)) {
            if (openLinksInWebView) {
                let svc = SFSafariViewController(url: link, entersReaderIfAvailable: false)
                if #available(iOS 10.0, *) {
                    if let barColor = self.webViewBarColor {
                        svc.preferredBarTintColor = barColor
                    }
                    if let controlColor = self.webViewControlColor {
                        svc.preferredControlTintColor = controlColor
                    }
                } else {
                    // Fallback on earlier versions
                }
                present(svc, animated: true, completion: nil)
            } else {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(link, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(link)
                }
            }
        } else {
            print("CAN'T OPEN URL: " + link.absoluteString)
        }
    }
}

extension NITContentViewController : UITextViewDelegate {
    public func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange) -> Bool {
        self.openUrl(url: url)
        return false
    }
}
