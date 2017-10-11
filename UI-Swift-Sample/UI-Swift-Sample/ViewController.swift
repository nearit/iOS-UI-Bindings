//
//  ViewController.swift
//  UI-Swift-Sample
//
//  Created by francesco.leoni on 30/08/17.
//  Copyright © 2017 Near. All rights reserved.
//

import UIKit
import NeariOSUI

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        title = "Sample"
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func showPermissionsDialog() {
        let aViewController = NITPermissionsViewController()
        aViewController.show()
    }
    
    func showPermissionsDialogCustom() {
        let baseUnknownImage = UIImage(named: "gray-button")
        let unknownImage = baseUnknownImage?.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 35, bottom: 0, right: 35))
        
        let baseGrantedImage = UIImage(named: "blue-button")
        let grantedImage = baseGrantedImage?.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 35, bottom: 0, right: 35))
        
        let aViewController = NITPermissionsViewController()
        aViewController.headerImage = UIImage(named: "NearIT")
        aViewController.textColor = UIColor.black
        aViewController.isEnableTapToClose = true
        aViewController.unknownButton = unknownImage
        aViewController.grantedButton = grantedImage
        aViewController.grantedIcon = UIImage(named: "green-dot")
        aViewController.locationText = "Turn on location"
        aViewController.notificationsText = "Turn on notications"
        aViewController.explainText = "We'll notify you of content that's interesting"
        aViewController.show { (dialogController: NITDialogController) in
            dialogController.backgroundStyle = .blur
        }
    }
    
    func showPermissionsDialogLocationsOnly() {
        let aViewController = NITPermissionsViewController(type: .locationOnly)
        aViewController.show()
    }

    func presentTheSameControllerAsAModalOne() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "main controller") {
            present(vc, animated: true, completion: nil)
        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 4
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sampleCell")!
        
        let title = cell.viewWithTag(40) as? UILabel
        let description = cell.viewWithTag(50) as? UILabel
        
        switch indexPath.section {
        case 0: // Permissions
            switch indexPath.row {
            case 0:
                title?.text = "Default permissions"
                description?.text = "Request permissions for locations and notifications"
            case 1:
                title?.text = "Custom permissions"
                description?.text = "Custom UI"
            case 2:
                title?.text = "Permissions"
                description?.text = "Locations Only"
            case 3:
                title?.text = NSLocalizedString("Present as a modal controller",
                                                comment: "Mainview -> present the mainview as a modal controller")
                description?.text = "Test popups when they are presented from a modal controller; handy to test complex controllers hierarchy"
            default:
                title?.text = "Undefined"
                description?.text = " - "
            }
        default:
            title?.text = "Undefined"
            description?.text = " - "
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0: // Permissions
            switch indexPath.row {
            case 0:
                showPermissionsDialog()
            case 1:
                showPermissionsDialogCustom()
            case 2:
                showPermissionsDialogLocationsOnly()
            case 3:
                presentTheSameControllerAsAModalOne()
            default:
                break
            }
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Permissions"
        default:
            return nil
        }
    }
}
