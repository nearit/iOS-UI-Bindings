//
//  NITPermissionsViewController.swift
//  Near-iOS-UI
//
//  Created by francesco.leoni on 30/08/17.
//  Copyright © 2017 Near. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

@objc public enum NITPermissionsType: NSInteger {
    case locationOnly = 0
    case notificationsOnly
    case locationAndNotifications
}

@objc public enum NITPermissionsLocationType: NSInteger {
    case always = 0
    case whenInUse = 1
}

public class NITPermissionsViewController: NITBaseViewController {
    
    @IBOutlet weak var explain: UILabel!
    @IBOutlet weak var location: UIButton!
    @IBOutlet weak var notification: UIButton!
    @IBOutlet weak var footer: UIButton!
    @IBOutlet weak var header: UIImageView!
    @IBOutlet weak var locationContainer: UIView!
    @IBOutlet weak var notificationsContainer: UIView!
    var unknownButton: UIImage!
    var grantedButton: UIImage!
    var grantedIcon: UIImage!
    public var headerImage: UIImage!
    public var textColor: UIColor!
    let permissionsManager = NITPermissionsManager()
    public var type: NITPermissionsType
    public var locationType: NITPermissionsLocationType
    
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
        self.init(type: .locationAndNotifications, locationType: .always)
    }
    
    public convenience init(locationType: NITPermissionsLocationType) {
        self.init(type: .locationAndNotifications, locationType: locationType)
    }
    
    public convenience init(type: NITPermissionsType) {
        self.init(type: type, locationType: .always)
    }
    
    public init(type: NITPermissionsType = .locationAndNotifications, locationType: NITPermissionsLocationType = .always) {
        self.type = type
        self.locationType = locationType
        
        let bundle = Bundle(for: NITDialogController.self)
        super.init(nibName: "NITPermissionsViewController", bundle: bundle)
        
        setupDefaultElements()
        permissionsManager.delegate = self
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupDefaultElements() {
        let bundle = Bundle(for: NITDialogController.self)
        let emptyOutline = UIImage(named: "outlinedButton", in: bundle, compatibleWith: nil)
        unknownButton = emptyOutline?.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 45, bottom: 0, right: 45))
        let filledOutline = UIImage(named: "filledButton", in: bundle, compatibleWith: nil)
        grantedButton = filledOutline?.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 45, bottom: 0, right: 45))
        grantedIcon = UIImage(named: "tick", in: bundle, compatibleWith: nil)
        headerImage = UIImage(named: "permissionsBanner", in: bundle, compatibleWith: nil)
        textColor = UIColor.nearWarmGrey
    }
    
    internal func setupUI() {
        switch type {
        case .locationAndNotifications:
            locationContainer.isHidden = false
            notificationsContainer.isHidden = false
        case .locationOnly:
            locationContainer.isHidden = false
            notificationsContainer.isHidden = true
        case .notificationsOnly:
            locationContainer.isHidden = true
            notificationsContainer.isHidden = false
        }
        
        explain.textColor = textColor
        footer.tintColor = textColor
        
        location.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        location.setBackgroundImage(unknownButton, for: .normal)
        notification.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        notification.setBackgroundImage(unknownButton, for: .normal)
        header.image = headerImage
        
        if #available(iOS 10.0, *) {
            permissionsManager.isNotificationAvailable({ (available) in
                if available {
                    self.confirmNotificationButton()
                }
            })
        } else {
            if permissionsManager.isNotificationAvailable() {
                confirmNotificationButton()
            }
        }
        
        var authorizationStatus: CLAuthorizationStatus!
        switch locationType {
        case .always:
            authorizationStatus = .authorizedAlways
        case .whenInUse:
            authorizationStatus = .authorizedWhenInUse
        }
        
        if permissionsManager.isLocationGranted(status: authorizationStatus) {
            confirmLocationButton()
        }
    }
    
    @IBAction func tapFooter(_ sender: Any) {
        dialogController?.dismiss()
    }
    
    // MARK: - Permission buttons
    
    @IBAction func tapLocation(_ sender: Any) {
        permissionsManager.requestLocationPermission()
    }
    
    @IBAction func tapNotifications(_ sender: Any) {
        permissionsManager.requestNotificationsPermission()
    }
    
    func confirmLocationButton() {
        location.setBackgroundImage(grantedButton, for: .normal)
        location.setTitleColor(UIColor.white, for: .normal)
        location.setImage(grantedIcon, for: .normal)
    }
    
    func confirmNotificationButton() {
        notification.setBackgroundImage(grantedButton, for: .normal)
        notification.setTitleColor(UIColor.white, for: .normal)
        notification.setImage(grantedIcon, for: .normal)
    }
    
    /// Present permissions view controller from the rootViewController if it exists
    public func show() {
        if let viewController = UIApplication.shared.keyWindow?.rootViewController {
            self.show(fromViewController: viewController)
        }
    }
    
    /**
     Present permissions view controller from a view controller
     - Parameter fromViewController: view controller used to present the permissions view controller
     */
    public func show(fromViewController: UIViewController) {
        let dialog = NITDialogController(viewController: self)
        fromViewController.present(dialog, animated: true, completion: nil)
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

extension NITPermissionsViewController: NITPermissionsManagerDelegate {
    
    func permissionsManager(_ manager: NITPermissionsManager, didGrantLocationAuthorization granted: Bool) {
        if (granted) {
            confirmLocationButton()
        }
    }
    
    func permissionsManagerDidRequestNotificationPermissions(_ manager: NITPermissionsManager) {
        confirmNotificationButton()
    }
}
