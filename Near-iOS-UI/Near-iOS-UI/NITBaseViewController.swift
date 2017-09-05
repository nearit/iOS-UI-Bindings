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
    var isEnableTapToClose: Bool {
        get {
            if let dialogController = dialogController {
                return dialogController.isEnableTapToClose
            }
            return false
        }
        set(enabled) {
            dialogController?.isEnableTapToClose = enabled
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
