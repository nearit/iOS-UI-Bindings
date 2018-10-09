//
//  ViewController.swift
//  UI-Swift-Sample
//
//  Created by francesco.leoni on 30/08/17.
//  Copyright © 2017 Near. All rights reserved.
//

import UIKit
import NearITSDK
import NearUIBinding
import WebKit

enum Code: Int {
    case swift = 0
    case objectiveC = 1
}

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var codeSegment: UISegmentedControl!

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
        switch codeSegment.selectedSegmentIndex {
            case Code.swift.rawValue:
                let aViewController = NITPermissionsViewController()
                aViewController.show()
            case Code.objectiveC.rawValue:
                ObjCUIManager.sharedInstance().showPermissiongDialog()
            default:
                print("Code undefined")
        }
    }
    
    func getPermissionDialogCustom() -> NITPermissionsViewController {
        let baseUnknownImage = UIImage(named: "gray-button")
        let unknownImage = baseUnknownImage?.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 35, bottom: 0, right: 35))
        
        let baseGrantedImage = UIImage(named: "blue-button")
        let grantedImage = baseGrantedImage?.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 35, bottom: 0, right: 35))
        
        let aViewController = NITPermissionsViewController()
        aViewController.headerImage = UIImage(named: "NearIT")
        aViewController.textColor = UIColor.black
        aViewController.isEnableTapToClose = true
        
        aViewController.checkedButtonColor = UIColor.green
        
        aViewController.happyImage = unknownImage
        aViewController.sadImage = grantedImage
        
        aViewController.grantedIcon = UIImage(named: "green-dot")
        aViewController.locationText = "Turn on location"
        aViewController.notificationsText = "Turn on notications"
        aViewController.explainText = "We'll notify you of content that's interesting"
        aViewController.autoCloseDialog = .on
        return aViewController
    }
    
    func showPermissionsDialogCustom() -> NITPermissionsViewController {
        let permissionViewControler = getPermissionDialogCustom()
        permissionViewControler.show { (dialogController: NITDialogController) in
            dialogController.backgroundStyle = .blur
        }

        return permissionViewControler
    }
    
    func showPermissionsDialogLocationsOnly() {
        let aViewController = NITPermissionsViewController(type: .locationOnly)
        aViewController.show()
    }

    func showFeedbackDialog(question: String) {
        let feedback = NITFeedback()
        feedback.question = question
        feedback.recipeId = "ffe0"

        switch codeSegment.selectedSegmentIndex {
        case Code.swift.rawValue:
            let aViewController = NITFeedbackViewController(feedback: feedback)
            aViewController.show()
        case Code.objectiveC.rawValue:
            ObjCUIManager.sharedInstance().showFeedbackDialog(feedback)
        default:
            print("Code undefined")
        }
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
        aViewController.disappearTime = 2.0
        aViewController.show(fromViewController: nil) { (dialogController: NITDialogController) in
            dialogController.backgroundStyle = .blur
        }
    }

    func showCouponDialog(coupon: NITCoupon) {
        switch codeSegment.selectedSegmentIndex {
        case Code.swift.rawValue:
            let aViewController = NITCouponViewController(coupon: coupon)
            aViewController.show()
        case Code.objectiveC.rawValue:
            ObjCUIManager.sharedInstance().showCouponDialog(coupon)
        default:
            print("Code undefined")
        }
    }

    func showCouponDialogCustom(coupon: NITCoupon) {
        let aViewController = NITCouponViewController(coupon: coupon)
        aViewController.separatorImage = UIImage(named: "Line")
        aViewController.separatorBackgroundColor = .white
        aViewController.couponValidColor = .black
        aViewController.validFont = UIFont.systemFont(ofSize: 18.0)
        aViewController.fromToFont = UIFont.systemFont(ofSize: 22.0)
        aViewController.descriptionFont = UIFont.boldSystemFont(ofSize: 25.0)
        aViewController.valueFont = UIFont.italicSystemFont(ofSize: 25.0)
        aViewController.valueColor = .purple
        aViewController.iconPlaceholder = UIImage(named: "NearIT")
        aViewController.show(fromViewController: nil) { (dialogController: NITDialogController) in
            dialogController.backgroundStyle = .blur
        }
    }

    func pushCoupon(coupon: NITCoupon) {
        let aViewController = NITCouponViewController(coupon: coupon)
        aViewController.show(navigationController: navigationController!)
    }

    func showContentDialog(content: NITContent) {
        switch codeSegment.selectedSegmentIndex {
        case Code.swift.rawValue:
            let aViewController = NITContentViewController(content: content)
            aViewController.openLinksInWebView = true
            aViewController.webViewBarColor = UIColor.black
            aViewController.webViewControlColor = UIColor.white
            aViewController.show()
        case Code.objectiveC.rawValue:
            ObjCUIManager.sharedInstance().showContenDialog(content)
        default:
            print("Code undefined")
        }
    }

    func showCustomContentDialog(content: NITContent) {
        let aViewController = NITContentViewController(content: content)

        aViewController.imagePlaceholder = UIImage.init(named: "NearIT")
        aViewController.linkHandler = { (controller, request) -> WKNavigationActionPolicy in
            let ui = UIAlertController.init(title: "Link tapped", message: "URL: \(request.url!)", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "Ok", style: .default)
            ui.addAction(okAction)
            controller.present(ui, animated: true)
            return .cancel
        }
        aViewController.callToActionHandler = { (controller, url) -> Void in
            let ui = UIAlertController.init(title: "Call To Action", message: "URL: \(url)", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "Ok", style: .default)
            ui.addAction(okAction)
            controller.present(ui, animated: true)
        }

        aViewController.show(fromViewController: nil) { (dialogController: NITDialogController) in
            dialogController.backgroundStyle = .blur
        }
    }

    func pushContent(content: NITContent) {
        let aViewController = NITContentViewController(content: content)
        aViewController.show(navigationController: navigationController!)
    }

    func createExpiredCoupon() -> NITCoupon {
        let coupon = NITCoupon()
        coupon.couponDescription = "Description"
        coupon.value = "10 $"
        coupon.expiresAt = "2017-06-05T08:32:00.000Z"
        coupon.redeemableFrom = "2017-06-01T08:32:00.000Z"
        let claim = NITClaim()
        claim.serialNumber = "0123456789"
        coupon.claims = [claim]
        coupon.icon = NITImage()
        coupon.icon.image = ["square_300": ["url": "https://avatars0.githubusercontent.com/u/18052069?s=200&v=4"]]
        return coupon
    }

    func createValidCoupon() -> NITCoupon {
        let coupon = NITCoupon()
        coupon.couponDescription = "Long coupon description, Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna ali."
        coupon.value = "Value qwertyuioplkjhgfdsazxcvbnmpoiuytrewqasdfghj!"
        coupon.expiresAt = "3017-06-05T08:32:00.000Z"
        let claim = NITClaim()
        claim.serialNumber = "0123456789"
        coupon.claims = [claim]
        coupon.icon = NITImage()
        return coupon
    }

    func createInactiveCoupon() -> NITCoupon {
        let coupon = NITCoupon()
        coupon.couponDescription = "Description"
        coupon.value = "10 $"
        coupon.redeemableFrom = "3017-06-05T08:32:00.000Z"
        let claim = NITClaim()
        claim.serialNumber = "0123456789"
        coupon.claims = [claim]
        coupon.icon = NITImage()
        return coupon
    }

    func pushCouponList(modal: Bool = false) {
        switch codeSegment.selectedSegmentIndex {
        case Code.swift.rawValue:
            let aViewController = NITCouponListViewController()
            if modal {
                aViewController.show()
                aViewController.couponBackground = .normalBorders
            } else {
                aViewController.show(navigationController: navigationController!, title: "my coupons")
            }
        case Code.objectiveC.rawValue:
            ObjCUIManager.sharedInstance().showListOfCoupons()
        default:
            print("Code undefined")
        }
    }

    func customPushCouponList() {
        let aViewController = NITCouponListViewController()
        aViewController.presentCoupon = .popover
        aViewController.filterOption = .valid
        aViewController.valueFont = UIFont.boldSystemFont(ofSize: 30)
        aViewController.show()
    }

    func permissionBar() {
        let vc = UIViewController.init()
        vc.view.backgroundColor = .white

        let permissionViewA = NITPermissionsView.init(frame: CGRect.zero)
        permissionViewA.locationType = .always
        vc.view.addSubview(permissionViewA)

        NSLayoutConstraint.activate([
            permissionViewA.leftAnchor.constraint(equalTo: vc.view.leftAnchor),
            permissionViewA.rightAnchor.constraint(equalTo: vc.view.rightAnchor),
            permissionViewA.topAnchor.constraint(equalTo: vc.topLayoutGuide.bottomAnchor),
        ])

        let permissionViewB = NITPermissionsView.init(frame: CGRect.zero)
        permissionViewB.permissionsRequired = .locationAndNotifications
        permissionViewB.locationType = .whenInUse
        permissionViewB.backgroundColor = .gray
        permissionViewB.messageColor = .black
        permissionViewB.messageFont = UIFont.boldSystemFont(ofSize: 15.0)
//        permissionViewB.permissionAvailableColor = .green
//        permissionViewB.permissionNotAvailableColor = .red
//        permissionViewB.buttonText = "Roger"
//        permissionViewB.buttonColor = .white

       
        permissionViewB.callbackOnPermissions = { (view) in
            let vc = self.getPermissionDialogCustom()
            vc.autoCloseDialog = .off
            vc.locationType = .whenInUse
            vc.delegate = view
            vc.show()
        }
        vc.view.addSubview(permissionViewB)

        NSLayoutConstraint.activate([
            permissionViewB.leftAnchor.constraint(equalTo: vc.view.leftAnchor),
            permissionViewB.rightAnchor.constraint(equalTo: vc.view.rightAnchor),
            permissionViewB.topAnchor.constraint(equalTo: permissionViewA.bottomAnchor, constant: 20.0)
            ])

        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showHistoryInNavigationController(_ customNoContent: Bool = false) {
        switch codeSegment.selectedSegmentIndex {
        case Code.swift.rawValue:
            let history = NITNotificationHistoryViewController()
            history.includeCoupons = true;
            if customNoContent {
                let view = UIView()
                view.backgroundColor = UIColor.blue
                history.noContentView = view
            }
            history.unreadColor = UIColor(red: 99.0/255.0, green: 182.0/255.0, blue: 1.0, alpha: 1.0)
            // inbox.show(navigationController: navigationController!)
            history.show(navigationController: navigationController!, title: "my notifications")
        case Code.objectiveC.rawValue:
            if customNoContent {
                let view = UIView()
                view.backgroundColor = UIColor.orange
                ObjCUIManager.sharedInstance().showHistory(with: navigationController!, customNoContent: view)
            } else {
                ObjCUIManager.sharedInstance().showHistory(with: navigationController!)
            }
            
        default:
            print("Code undefined")
        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        case 1:
            return 2
        case 2:
            return 5
        case 3:
            return 4
        case 4:
            return 3
        case 5:
            return 1
        case 6:
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
        case 2: // Coupon
            switch indexPath.row {
            case 0:
                title?.text = "Default coupon, valid"
                description?.text = "Show qrcode and all informations"
            case 1:
                title?.text = "Default coupon, expired"
                description?.text = "With remote icon"
            case 2:
                title?.text = "Default coupon, inactive"
                description?.text = "No qrcode and 'disabled' look"
            case 3:
                title?.text = "Custom coupon"
                description?.text = "Valid with custom fonts/colors"
            case 4:
                title?.text = "Navigation controller coupon"
                description?.text = "Like a default coupon but pushed"
            default:
                title?.text = "Undefined"
                description?.text = " - "
            }
        case 3: // Content
            switch indexPath.row {
            case 0:
                title?.text = "Default content"
                description?.text = "Simple text"
            case 1:
                title?.text = "Default content"
                description?.text = "With call to action"
            case 2:
                title?.text = "Custom content"
                description?.text = "With custom handlers"
            case 3:
                title?.text = "Navigation controller content"
                description?.text = "Like a default content but pushed"
            default:
                title?.text = "Undefined"
                description?.text = " - "
            }
        case 4: // Coupon list
            switch indexPath.row {
            case 0:
                title?.text = "Coupon list"
                description?.text = "Navigation controller"
            case 1:
                title?.text = "Coupon list"
                description?.text = "Modal"
            case 2:
                title?.text = "Custom coupon list"
                description?.text = "Modal"
            default:
                title?.text = "Undefined"
                description?.text = " - "
            }
        case 5: // Permission bar
            title?.text = "Coupon permission bar"
            description?.text = "Creted by code"
        case 6: // History
            switch indexPath.row {
            case 0:
                title?.text = "Notification history"
                description?.text = "Navigation controller"
            case 1:
                title?.text = "Notification history"
                description?.text = "Navigation controller with no content view"
            default:
                title?.text = "Undefined History"
                description?.text = " - "
            }
        default:
            title?.text = "Undefined"
            description?.text = " - "
        }

        return cell
    }

    func lorem() -> String {
        return "<h1>my h1 title</h1><b>Just some bold text</b> Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0: // Permissions
            switch indexPath.row {
            case 0:
                showPermissionsDialog()
            case 1:
                _ = showPermissionsDialogCustom()
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
                showFeedbackDialogCustom(question: lorem())
            default:
                break
            }
        case 2: // Coupon
            switch indexPath.row {
            case 0:
                let coupon = createValidCoupon()
                showCouponDialog(coupon: coupon)
            case 1:
                let coupon = createExpiredCoupon()
                showCouponDialog(coupon: coupon)
            case 2:
                let coupon = createInactiveCoupon()
                showCouponDialog(coupon: coupon)
            case 3:
                let coupon = createValidCoupon()
                showCouponDialogCustom(coupon: coupon)
            case 4:
                let coupon = createValidCoupon()
                pushCoupon(coupon: coupon)
            default:
                break
            }
        case 3: // Content
            switch indexPath.row {
            case 0:
                let content = NITContent()
                content.content = "<a href='https://www.nearit.com'>LINK</a></br>\(lorem())"
                content.title = "At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis"
                showContentDialog(content: content)
            case 1:
                let content = MockContent()
                content.title = "My Title"
                content.content = "<a href='https://www.nearit.com'>LINK</a></br>\(lorem())"
                content.mockLink = NITContentLink()
                content.mockLink?.label = "Eat the cake"
                content.mockLink?.url = URL(string: "http://www.eatBigCakes.com")!
                let mockImage = MockImage()
                mockImage.mockUrl = URL(string: "https://images-na.ssl-images-amazon.com/images/I/71B4TCc3gFL._SL1000_.jpg")
                content.mockImage = mockImage
                showContentDialog(content: content)
            case 2:
                let content = MockContent()
                content.title = "My Title"
                content.content = "<a href='https://www.nearit.com'>LINK</a></br>\(lorem())"
                content.mockLink = NITContentLink()
                content.mockLink?.label = "Eat the cake"
                content.mockLink?.url = URL(string: "http://www.eatBigCakes.com")!
                showCustomContentDialog(content: content)
            case 3:
                let content = MockContent()
                content.title = "Navigation content"
                content.content = "<a href='https://www.nearit.com'>LINK</a></br>\(lorem())"
                let mockImage = MockImage()
                mockImage.mockUrl = URL(string: "https://images-na.ssl-images-amazon.com/images/I/71B4TCc3gFL._SL1000_.jpg")
                content.mockImage = mockImage
                pushContent(content: content)
            default:
                break
            }
        case 4:
            switch indexPath.row {
            case 0:
                pushCouponList(modal: false)
            case 1:
                pushCouponList(modal: true)
            case 2:
                customPushCouponList()
            default:
                break
            }
        case 5:
            permissionBar()
        case 6:
            switch indexPath.row {
            case 0:
                showHistoryInNavigationController()
            case 1:
                showHistoryInNavigationController(true)
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
        case 2:
            return "Coupon"
        case 3:
            return "Content"
        case 4:
            return "Coupon list"
        case 5:
            return "Permission bar"
        case 6:
            return "History list"
        default:
            return nil
        }
    }
}
