//
//  NITContentViewController
//  NeariOSUI
//
//  Created by Nicola Ferruzzi on 31/10/2017.
//  Copyright © 2017 Near. All rights reserved.
//

import UIKit
import NearITSDK
import WebKit

public class NITWKWebViewContainer: UIView {
    var wkWebView: WKWebView!
    var font: UIFont = UIFont.systemFont(ofSize: 15.0)
    var heightConstraint: NSLayoutConstraint!

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        let configuration = WKWebViewConfiguration()
        wkWebView = WKWebView.init(frame: bounds, configuration: configuration)
        wkWebView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(wkWebView)
        wkWebView.scrollView.isScrollEnabled = false

        wkWebView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        wkWebView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        wkWebView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        wkWebView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        addObserver(self,
                    forKeyPath: #keyPath(wkWebView.scrollView.contentSize),
                    options: [.new, .old],
                    context: nil)

        heightConstraint = NSLayoutConstraint.init(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 100)
        addConstraint(heightConstraint)
    }

    deinit {
        removeObserver(self, forKeyPath: #keyPath(wkWebView.scrollView.contentSize))
    }

    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == #keyPath(wkWebView.scrollView.contentSize)) {
            if let change = change {
                if let old = change[.oldKey] as? CGSize, let new = change[.newKey] as? CGSize {
                    if old != new {
                        debugPrint(old, new)
                        heightConstraint.constant = new.height
                    }
                }
            }
        }
    }

    public func loadContent(content: NITContent?) {
        let content = content?.content ?? ""
        let inputText = "<meta name='viewport' content='initial-scale=1.0'/><style>body { font-family: '\(font.fontName)'; font-size:\(font.pointSize)px; } </style>\(content)"
        wkWebView.loadHTMLString(inputText, baseURL: nil)
    }
}

public class NITContentViewController: NITBaseViewController {
    var content: NITContent!
    var nearManager: NITManager
    var closeCallback: ((NITContentViewController) -> Void)?

    public var drawSeparator = true
    public var hideCloseButton = false
    public var imagePlaceholder: UIImage!
    public var titleFont = UIFont.boldSystemFont(ofSize: 18.0)
    public var titleColor = UIColor.nearBlack

    @IBOutlet weak var close: UIButton!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var contentTitle: UILabel!
    @IBOutlet weak var titleContainer: UIView!
    @IBOutlet weak var webviewContainer: NITWKWebViewContainer!
    @IBOutlet weak var stackviewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackview: UIStackView!

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
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    internal func setupUI() {
        dialogController?.contentView.backgroundColor = .clear
        close.isHidden = hideCloseButton

        image.image = imagePlaceholder

        contentTitle.textColor = titleColor
        contentTitle.font = titleFont
        contentTitle.text = content.title

        webviewContainer.loadContent(content: content)
    }

    @IBAction func tapClose(_ sender: Any) {
        if let closeCallback = closeCallback {
            closeCallback(self)
        } else {
            dialogController?.dismiss()
        }
    }

}
