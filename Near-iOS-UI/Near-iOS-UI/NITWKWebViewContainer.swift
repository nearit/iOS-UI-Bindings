//
//  NITWKWebViewContainer.swift
//  NeariOSUI
//
//  Created by Nicola Ferruzzi on 01/11/2017.
//  Copyright © 2017 Near. All rights reserved.
//

import Foundation
import WebKit
import NearITSDK

// There are two strategy to adapt the view to the content of the DOM.
// The correct one is observing the WKWebView scrollView for its contentSize;
// it usually works but sometimes (totally random) its just bigger than the
// actual content.
// The second strategy is to read the scrollHeight from the DOM; usually correct
// still it does not react to dynamic changes; not relevant with just texts and no js.
fileprivate enum NITWKWebViewContainerSizeType: Int {
    case contentSize = 0
    case scrollHeight
}

internal class NITWKWebViewContainer: UIView, WKNavigationDelegate {
    public var font: UIFont = UIFont.init(name: "Helvetica", size: 15.0) ?? UIFont.systemFont(ofSize: 15.0)
    public var linkHandler: ((URLRequest) -> WKNavigationActionPolicy)?

    @objc var wkWebView: WKWebView = {
        let view = WKWebView.init()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var heightConstraint: NSLayoutConstraint!

    fileprivate let sizeType = NITWKWebViewContainerSizeType.scrollHeight

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        addSubview(wkWebView)
        wkWebView.scrollView.isScrollEnabled = false
        wkWebView.scrollView.contentInset = .init(top: 0, left: 0, bottom: 0, right: 0)

        wkWebView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        wkWebView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        wkWebView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        wkWebView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        if sizeType == .contentSize {
            addObserver(self,
                        forKeyPath: #keyPath(wkWebView.scrollView.contentSize),
                        options: [.new, .old],
                        context: nil)
        }

        heightConstraint = NSLayoutConstraint.init(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 1)
        addConstraint(heightConstraint)

        wkWebView.navigationDelegate = self
    }

    deinit {
        if sizeType == .contentSize {
            removeObserver(self, forKeyPath: #keyPath(wkWebView.scrollView.contentSize))
        }
    }

    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == #keyPath(wkWebView.scrollView.contentSize)) {
            if let change = change {
                if let old = change[.oldKey] as? CGSize, let new = change[.newKey] as? CGSize {
                    if old != new {
                        heightConstraint.constant = new.height
                    }
                }
            }
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if sizeType != .scrollHeight { return }
        webView.evaluateJavaScript("document.readyState", completionHandler: { (complete, error) in
            if complete != nil {
                webView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { [weak self](height, error) in
                    // swiftlint:disable force_cast
                    self?.heightConstraint.constant = height as! CGFloat
                })
            }
        })
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void)
    {
        if navigationAction.navigationType == .linkActivated, let linkHandler = linkHandler {
            decisionHandler(linkHandler(navigationAction.request))
        } else {
            decisionHandler(.allow)
        }
    }

    public func loadContent(content: NITContent?) {
        let content = content?.content ?? ""
        let inputText = "<meta name='viewport' content='initial-scale=1.0'/><style>body { font-family: '\(font.fontName)'; font-size:\(font.pointSize)px; } </style>\(content)"
        wkWebView.loadHTMLString(inputText, baseURL: nil)
    }
}
