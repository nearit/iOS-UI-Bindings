//
//  NITPermissionsViewController.swift
//  Near-iOS-UI
//
//  Created by francesco.leoni on 30/08/17.
//  Copyright © 2017 Near. All rights reserved.
//

import UIKit

public class NITPermissionsViewController: NITBaseViewController {
    
    @IBOutlet weak var explain: UILabel!
    @IBOutlet weak var location: UIButton!
    @IBOutlet weak var notification: UIButton!
    @IBOutlet weak var footer: UIButton!
    var outlinedButton: UIImage!
    var filledButton: UIImage!
    
    public var explainText: String? {
        get {
            return explain.text
        }
        set(text) {
            explain.text = text
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public convenience init() {
        // Get Current Bundle
        let bundle = Bundle(for: NITDialogController.self)
        
        // Create New Instance Of Alert Controller
        self.init(nibName: "NITPermissionsViewController", bundle: bundle)
    }
    
    internal func setupUI() {
        let bundle = Bundle(for: NITDialogController.self)
        let emptyOutline = UIImage(named: "outlinedButton", in: bundle, compatibleWith: nil)
        outlinedButton = emptyOutline?.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 45, bottom: 0, right: 45))
        let filledOutline = UIImage(named: "filledButton", in: bundle, compatibleWith: nil)
        filledButton = filledOutline?.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 45, bottom: 0, right: 45))
        
        explain.textColor = UIColor.nearWarmGrey
        footer.tintColor = UIColor.nearWarmGrey
        
        location.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        location.setBackgroundImage(outlinedButton, for: .normal)
        notification.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        notification.setBackgroundImage(outlinedButton, for: .normal)
    }
    
    @IBAction func tapFooter(_ sender: Any) {
        dialogController?.dismiss()
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
