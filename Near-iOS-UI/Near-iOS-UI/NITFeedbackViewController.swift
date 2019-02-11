//
//  NITFeedbackViewController.swift
//  NeariOSUI
//
//  Created by Nicola Ferruzzi on 16/10/2017.
//  Copyright © 2017 Near. All rights reserved.
//

import UIKit
import NearITSDK

@objc public enum NITFeedbackCommentVisibility: NSInteger {
    case visible
    case hidden
    case onRating
}

public typealias NITFeedbackCallback = ((NITFeedbackViewController, Int, String?, @escaping (Bool)->(Void)) -> Void)

public class NITFeedbackViewController: NITBaseViewController {
    var feedback: NITFeedback!
    var nearManager: NITManager

    @objc public var feedbackSendCallback: NITFeedbackCallback?
    @objc public var sendButton: UIImage!
    @objc public var rateFullButton: UIImage!
    @objc public var rateEmptyButton: UIImage!
    @objc public var textColor: UIColor = NITUIAppearance.sharedInstance.nearBlack()
    @objc public var textFont: UIFont?
    @objc public var commentDescriptionTextColor = NITUIAppearance.sharedInstance.nearGrey()
    @objc public var errorColor: UIColor = NITUIAppearance.sharedInstance.nearRed()
    @objc public var errorFont: UIFont?

    @objc public var commentVisibility: NITFeedbackCommentVisibility = .onRating {
        didSet {
            if isViewLoaded {
                setupCommentVisibility(hidden: commentVisibility != .visible)
            }
        }
    }

    @objc public var closeText: String!
    @objc public var commentDescriptionText: String!
    @objc public var sendText: String!
    @objc public var errorText: String!
    @objc public var retryText: String!
    @objc public var okText: String!

    @objc public var disappearTime: Double = 3.0 {
        didSet {
            disappearTimer = TimeInterval(floatLiteral: disappearTime)
        }
    }

    @IBOutlet weak var stackview: UIStackView!
    @IBOutlet weak var okContainer: UIView!
    @IBOutlet weak var send: UIButton!
    @IBOutlet weak var comment: UITextView!
    @IBOutlet var stars: [UIButton]!
    @IBOutlet weak var explanation: UILabel!
    @IBOutlet weak var close: UIButton!
    @IBOutlet weak var commentDescription: UILabel!
    @IBOutlet weak var error: UILabel!
    @IBOutlet weak var errorContainer: UIView!
    @IBOutlet weak var ok: UILabel!
    @IBOutlet var commentViews: [UIView]!
    @IBOutlet weak var sendContainer: UIView!

    var currentRating: Int = 0
    var disappearTimer: TimeInterval?

    @objc public convenience init(feedback: NITFeedback) {
        self.init(feedback: feedback, feedbackSendCallback: nil, manager: nil)
    }

    @objc public convenience init(feedback: NITFeedback, feedbackSendCallback: NITFeedbackCallback?) {
        self.init(feedback: feedback, feedbackSendCallback: feedbackSendCallback, manager: nil)
    }

    @objc init(feedback: NITFeedback, feedbackSendCallback: NITFeedbackCallback?, manager: NITManager?) {
        let bundle = Bundle.NITBundle(for: NITDialogController.self)
        self.feedbackSendCallback = feedbackSendCallback
        self.feedback = feedback
        self.nearManager = manager ?? NITManager.default()
        super.init(nibName: "NITFeedbackViewController", bundle: bundle)
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

    func setupDefaultElements() {
        let bundle = Bundle.NITBundle(for: NITDialogController.self)
        
        rateFullButton = UIImage(named: "star", in: bundle, compatibleWith: nil)
        rateEmptyButton = UIImage(named: "starEmpty", in: bundle, compatibleWith: nil)

        closeText = NSLocalizedString("Feedback dialog: Close", tableName: nil, bundle: bundle, value: "Close", comment: "Feedback dialog: Close")
        commentDescriptionText = NSLocalizedString("Feedback dialog: Leave a comment (optional):",
                                                   tableName: nil, bundle: bundle,
                                                   value: "Leave a comment (optional):",
                                                   comment: "Feedback dialog: Leave a comment (optional):")
        sendText = NSLocalizedString("Feedback dialog: SEND", tableName: nil, bundle: bundle, value: "SEND", comment: "Feedback dialog: SEND")
        errorText = NSLocalizedString("Feedback dialog: oops, an error occured!", tableName: nil, bundle: bundle, value: "Oops, an error occured!", comment: "Feedback dialog: oops, an error occured!")
        retryText = NSLocalizedString("Feedback dialog: retry", tableName: nil, bundle: bundle, value: "Retry", comment: "Feedback dialog: retry")
        okText = NSLocalizedString("Feedback dialog: Thank you for your feedback.",
                                   tableName: nil, bundle: bundle,
                                   value: "Thank you for your feedback.",
                                   comment: "Feedback dialog: Thank you for your feedback.")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShowNotification), name:
            UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    internal func setupUI() {
        send.setBackgroundImage(sendButton, for: .normal)
        send.setTitle(sendText, for: .normal)
        sendContainer.isHidden = true
        send.setRoundedButtonOf(color: NITUIAppearance.sharedInstance.nearBlack())

        comment.layer.cornerRadius = 5.0
        comment.layer.borderWidth = 1.0
        comment.layer.borderColor = UIColor.init(white: 225.0/255.0, alpha: 1.0).cgColor

        for rate in stars {
            rate.setImage(rateEmptyButton, for: .normal)
            rate.setImage(rateFullButton, for: .selected)
        }

        explanation.text = feedback.question

        close.setTitle(closeText, for: .normal)
        commentDescription.text = commentDescriptionText

        explanation.textColor = textColor
        commentDescription.textColor = commentDescriptionTextColor
        close.setTitleColor(textColor, for: .normal)

        error.text = errorText
        error.textColor = errorColor
        errorContainer.isHidden = true
        

        okContainer.isHidden = true
        ok.text = okText
        ok.textColor = textColor

        applyFont()
        
        setupCommentVisibility(hidden: commentVisibility != .visible)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.onViewTap(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func applyFont() {
        if let regularFont = NITUIAppearance.sharedInstance.regularFontName {
            explanation.changeFont(to: regularFont)
            ok.changeFont(to: regularFont)
            error.changeFont(to: regularFont)
        }
        if let italicFont = NITUIAppearance.sharedInstance.italicFontName {
            commentDescription.changeFont(to: italicFont)
            close.changeFont(to: italicFont)
        }
        if let boldFont = NITUIAppearance.sharedInstance.boldFontName {
            send.changeFont(to: boldFont)
        }
        
        
        if let textFont = textFont {
            explanation.font = textFont
            ok.font = textFont
        }
        if let errorFont = errorFont {
            error.font = errorFont
        }
    }
    
    @objc func onViewTap(_ gesture: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    @IBAction func onStarTouchUpInside(_ sender: UIButton) {
        var index = stars.index(of: sender)!
        let latest = stars.index(where: {
            $0.isSelected == false
        })
        // Remove below if you want [1..5] values only
        if let latest = latest {
            if (latest - 1) == index {
                index -= 1
            }
        } else {
            index -= 1
        }
        stars.forEach { $0.isSelected = stars.index(of: $0)! <= index }
        currentRating = index + 1

        let hideSendAndComment = !stars.reduce(false) { $0 || $1.isSelected }
        sendContainer.isHidden = hideSendAndComment

        if commentVisibility == .onRating {
            UIView.animate(withDuration: 0.4, delay: 0.0,
                           usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0,
                           options: [.curveEaseOut, .beginFromCurrentState, .allowUserInteraction],
                           animations: {[weak self]() -> Void in
                self?.setupCommentVisibility(hidden: hideSendAndComment)
                self?.view.layoutIfNeeded()
            })
        }
    }

    @IBAction func tapFooter(_ sender: Any) {
        dialogController?.dismiss()
    }

    @IBAction func tapSend(_ sender: Any) {
        if let feedbackSendCallback = feedbackSendCallback {
            let chain = { [weak self](ok: Bool) -> Void in
                if ok {
                    self?.nextOk()
                } else {
                    self?.nextError()
                }
            }
            feedbackSendCallback(self, currentRating, comment.text, chain)
        } else {
            let manager = nearManager
            let event = NITFeedbackEvent.init(feedback: feedback, rating: currentRating, comment: comment.text)
            manager.sendEvent(with: event, completionHandler: { [weak self](error: Error?) in
                if error != nil {
                    self?.nextError()
                } else {
                    self?.nextOk()
                }
            })
        }
    }

    internal func nextOk() {
        UIView.animate(withDuration: 0.4, delay: 0.0,
                       usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0,
                       options: [.curveEaseOut, .beginFromCurrentState, .allowUserInteraction],
                       animations: {[weak self]() -> Void in
            guard let wself = self else { return }
            wself.stackview.arrangedSubviews.forEach({ (view: UIView) in
                view.isHidden = view != wself.okContainer
            })
            wself.view.layoutIfNeeded()
            }, completion: { _ in })

        if let disappearTimer = disappearTimer {
            Timer.scheduledTimer(timeInterval: disappearTimer, target: self, selector: #selector(closeController), userInfo: nil, repeats: false)
        }
    }

    @objc func closeController() {
        dialogController?.dismiss()
    }

    internal func nextError() {
        UIView.animate(withDuration: 0.4, delay: 0.0,
                       usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0,
                       options: [.curveEaseOut, .beginFromCurrentState, .allowUserInteraction],
                       animations: {[weak self]() -> Void in
            guard let wself = self else { return }
            wself.errorContainer.isHidden = false
            wself.send.setRoundedButtonOf(color: NITUIAppearance.sharedInstance.nearRed())
            wself.send.setTitle(wself.retryText, for: .normal)
            wself.view.layoutIfNeeded()
        }, completion: { _ in })
    }

    internal func setupCommentVisibility(hidden: Bool) {
        commentViews.forEach({ $0.isHidden = hidden })
    }

}

// Keyboard extension

extension NITFeedbackViewController {
    
    @objc func keyboardDidShowNotification(notification: NSNotification) {
        if let scrollView = dialogController?.scrollView {
            let point = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height)
            scrollView.setContentOffset(point, animated: true)
        }
    }
}
