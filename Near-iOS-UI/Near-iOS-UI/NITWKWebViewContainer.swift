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

internal class NITWKWebViewContainer: UIView, WKNavigationDelegate {
    public var font: UIFont = UIFont.systemFont(ofSize: 15.0)
    public var linkHandler: ((URLRequest) -> WKNavigationActionPolicy)?

    var wkWebView: WKWebView!
    var heightConstraint: NSLayoutConstraint!

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        let configuration = WKWebViewConfiguration()
        wkWebView = WKWebView.init(frame: bounds, configuration: configuration)
        wkWebView.translatesAutoresizingMaskIntoConstraints = false
        wkWebView.navigationDelegate = self

        addSubview(wkWebView)
        wkWebView.scrollView.isScrollEnabled = false
        wkWebView.scrollView.contentInset = .init(top: 0, left: 0, bottom: 0, right: 0)

        wkWebView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        wkWebView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        wkWebView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        wkWebView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        addObserver(self,
                    forKeyPath: #keyPath(wkWebView.scrollView.contentSize),
                    options: [.new, .old],
                    context: nil)

        heightConstraint = NSLayoutConstraint.init(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 1)
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
                        heightConstraint.constant = new.height
                    }
                }
            }
        }
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
