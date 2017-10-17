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

    public var sendButton: UIImage!
    public var rateFullButton: UIImage!
    public var rateEmptyButton: UIImage!
    public var feedback: NITFeedback!

    @IBOutlet weak var send: UIButton!
    @IBOutlet weak var comment: UITextView!

    @IBOutlet var stars: [UIButton]!

    @IBOutlet weak var explanation: UILabel!

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
        comment.layer.cornerRadius = 5.0
        comment.layer.borderWidth = 1.0
        comment.layer.borderColor = UIColor.init(white: 225.0/255.0, alpha: 1.0).cgColor
        for rate in stars {
            rate.setImage(rateEmptyButton, for: .normal)
            rate.setImage(rateFullButton, for: .selected)
        }
        explanation.text = feedback.question
    }

    @IBAction func onStarTouchUpInside(_ sender: UIButton) {
        var unselected = false
        for rate in stars {
            rate.isSelected = !unselected
            if rate == sender {
                unselected = true
            }
        }
    }
}
