//
//  NITFeedbackViewController.swift
//  NeariOSUI
//
//  Created by Nicola Ferruzzi on 16/10/2017.
//  Copyright © 2017 Near. All rights reserved.
//

import UIKit
import NearITSDK

public class NITFeedbackViewController: NITBaseViewController {
    var feedback: NITFeedback!

    public var sendButton: UIImage!
    public var rateFullButton: UIImage!
    public var rateEmptyButton: UIImage!
    public var textColor: UIColor = UIColor.nearWarmGrey
    public var closeText = NSLocalizedString("Close", comment: "Feedback dialog: Close")
    public var commentDescriptionText = NSLocalizedString("Leave a comment (optional):", comment: "Feedback dialog: Leave a comment (optional):")
    public var sendText = NSLocalizedString("SEND", comment: "Feedback dialog: SEND")

    @IBOutlet weak var send: UIButton!
    @IBOutlet weak var comment: UITextView!
    @IBOutlet var stars: [UIButton]!
    @IBOutlet weak var explanation: UILabel!
    @IBOutlet weak var close: UIButton!
    @IBOutlet weak var commentDescription: UILabel!

    public init(feedback: NITFeedback) {
        let bundle = Bundle(for: NITDialogController.self)
        super.init(nibName: "NITFeedbackViewController", bundle: bundle)
        self.feedback = feedback
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
        let filledButton = UIImage(named: "filledButton", in: bundle, compatibleWith: nil)
        sendButton = filledButton?.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 45, bottom: 0, right: 45))
        rateFullButton = UIImage(named: "star", in: bundle, compatibleWith: nil)
        rateEmptyButton = UIImage(named: "starEmpty", in: bundle, compatibleWith: nil)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    internal func setupUI() {
        send.setBackgroundImage(sendButton, for: .normal)
        send.setTitle(sendText, for: .normal)

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
        commentDescription.textColor = textColor
        close.setTitleColor(textColor, for: .normal)
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
    }
}
