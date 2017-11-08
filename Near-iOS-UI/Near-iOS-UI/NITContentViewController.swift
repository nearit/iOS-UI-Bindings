//
//  NITContentViewController
//  NeariOSUI
//
//  Created by Nicola Ferruzzi on 31/10/2017.
//  Copyright © 2017 Near. All rights reserved.
//

import UIKit
import NearITSDK

public class NITContentViewController: NITBaseViewController {
    var content: NITContent!
    var nearManager: NITManager
    var closeCallback: ((NITContentViewController) -> Void)?

    public var drawSeparator = true
    public var hideCloseButton = false

    @IBOutlet weak var close: UIButton!
    
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
//        let bundle = Bundle(for: NITDialogController.self)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    internal func setupUI() {
        dialogController?.contentView.backgroundColor = .clear
        close.isHidden = hideCloseButton
    }

    @IBAction func tapClose(_ sender: Any) {
        if let closeCallback = closeCallback {
            closeCallback(self)
        } else {
            dialogController?.dismiss()
        }
    }

}
