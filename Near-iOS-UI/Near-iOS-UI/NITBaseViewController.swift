//
//  NITBaseViewController.swift
//  Near-iOS-UI
//
//  Created by francesco.leoni on 31/08/17.
//  Copyright © 2017 Near. All rights reserved.
//

import UIKit

public class NITBaseViewController: UIViewController {
    
    var dialogController: NITDialogController?
    private var _isEnableTapToClose: Bool = true
    @objc public var isEnableTapToClose: Bool {
        get {
            return _isEnableTapToClose
        }
        set(enabled) {
            dialogController?.isEnableTapToClose = enabled
            _isEnableTapToClose = enabled
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    public func applyImage(fromURL: URL!, toImageView: UIImageView!) {
        DispatchQueue.global(qos: .userInitiated).async {
            let data = try? Data(contentsOf: fromURL)
            if let imageData = data, let image = UIImage(data: imageData) {
                DispatchQueue.main.async {
                    UIView.transition(with: toImageView,
                                      duration: 0.0,
                                      options: .transitionCrossDissolve,
                                      animations: {
                                        toImageView.image = image
                    },
                                      completion: nil)
                }
            }
        }
    }
}
