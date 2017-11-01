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
    var nearManager: NITManager
    var closeCallback: ((NITContentViewController) -> Void)?

    public var linkHandler: ((URLRequest) -> WKNavigationActionPolicy)?
    public var callToActionHandler: ((URL) -> Void)?
    public var drawSeparator = true
    public var hideCloseButton = false
    public var imagePlaceholder: UIImage!
    public var titleFont = UIFont.boldSystemFont(ofSize: 18.0)
    public var titleColor = UIColor.nearBlack
    public var callToActionButton: UIImage!

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

    public init(content: NITContent, closeCallback: ((NITContentViewController) -> Void)? = nil, manager: NITManager = NITManager.default()) {
        let bundle = Bundle(for: NITDialogController.self)
        self.closeCallback = closeCallback
        self.content = content
        self.nearManager = manager
        super.init(nibName: "NITContentViewController", bundle: bundle)
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
        imagePlaceholder = UIImage(named: "imgSegnaposto", in: bundle, compatibleWith: nil)
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
        dialogController?.contentView.backgroundColor = .clear
        close.isHidden = hideCloseButton

        image.image = imagePlaceholder
        if let contentImage = getImage(),
            let url = contentImage.url() ?? contentImage.smallSizeURL() {
            applyImage(fromURL: url, toImageView: image)
        }

        contentTitle.textColor = titleColor
        contentTitle.font = titleFont
        contentTitle.text = content.title

        webviewContainer.linkHandler = { [weak self](request) in
            if let wself = self, let url = request.url {
                if let lh = wself.linkHandler {
                    return lh(request)
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
        } else {
            ctaContainer.isHidden = true
        }
    }

    @IBAction func tapClose(_ sender: Any) {
        if let closeCallback = closeCallback {
            closeCallback(self)
        } else {
            dialogController?.dismiss()
        }
    }

    @IBAction func tapCallToAction(_ sender: Any) {
        if let ctaHandler = callToActionHandler {
            ctaHandler(content.link!.url)
        } else {
            let s = SFSafariViewController(url: content.link!.url)
            present(s, animated: true, completion: nil)
        }
    }
}
