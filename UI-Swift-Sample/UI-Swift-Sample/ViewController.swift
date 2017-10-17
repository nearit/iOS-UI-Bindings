//
//  ViewController.swift
//  UI-Swift-Sample
//
//  Created by francesco.leoni on 30/08/17.
//  Copyright © 2017 Near. All rights reserved.
//

import UIKit
import NearITSDK
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
        aViewController.autoCloseDialog = .on
        aViewController.show { (dialogController: NITDialogController) in
            dialogController.backgroundStyle = .blur
        }
    }
    
    func showPermissionsDialogLocationsOnly() {
        let aViewController = NITPermissionsViewController(type: .locationOnly)
        aViewController.show()
    }

    func showFeedbackDialog(question: String) {
        let feedback = NITFeedback()
        feedback.question = question
        feedback.recipeId = "ffe0"

        let aViewController = NITFeedbackViewController(feedback: feedback)
        aViewController.show()
    }

    func showFeedbackDialogCustom(question: String) {
        let redEmptyButton = UIImage(named: "red-empty-dot")
        let redButton = UIImage(named: "red-dot")
        let blueButton = UIImage(named: "blue-button")
        let sendButton = blueButton?.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 35, bottom: 0, right: 35))

        let feedback = NITFeedback()
        feedback.question = question
        feedback.recipeId = "ffe0"

        let aViewController = NITFeedbackViewController(feedback: feedback)
        aViewController.sendButton = sendButton
        aViewController.rateEmptyButton = redEmptyButton
        aViewController.rateFullButton = redButton
        aViewController.commentDescriptionText = "Anything to say?"
        aViewController.closeText = "Not interested"
        aViewController.sendText = "Rate"
        aViewController.textColor = UIColor.black
        aViewController.okText = "Thank you for taking the time to provide us with your feedback.\n\nYour feedback is important to us and we will endeavour to respond to your feedback within 100 working days.\n\nIf your feedback is of an urgent nature, you can contact the Developer on +800HackerMenn"
        aViewController.textFont = UIFont.boldSystemFont(ofSize: 15.0)
        aViewController.errorFont = UIFont.boldSystemFont(ofSize: 20.0)
        aViewController.show { (dialogController: NITDialogController) in
            dialogController.backgroundStyle = .blur
        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        case 1:
            return 2
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sampleCell")!
        
        let title = cell.viewWithTag(40) as? UILabel
        let description = cell.viewWithTag(50) as? UILabel

        cell.backgroundColor = UIColor.yellow
        
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
            default:
                title?.text = "Undefined"
                description?.text = " - "
            }
        case 1: // Feedback
            switch indexPath.row {
            case 0:
                title?.text = "Default feedback"
                description?.text = "With comment field"
            case 1:
                title?.text = "Custom feedback"
                description?.text = "Custom UI with comment and long question"
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
            default:
                break
            }
        case 1: // Feedback
            switch indexPath.row {
            case 0:
                showFeedbackDialog(question: "What am I?")
            case 1:
                showFeedbackDialogCustom(question: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. ")
            default:
                break
            }
        default:
            break
        }

        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Permissions"
        case 1:
            return "Feedback"
        default:
            return nil
        }
    }
}
