//
//  NITCouponListViewController.swift
//  NeariOSUI
//
//  Created by Nicola Ferruzzi on 13/11/2017.
//  Copyright © 2017 Near. All rights reserved.
//

import UIKit
import NearITSDK

@objc public enum NITCouponListViewControllerPresentCoupon: NSInteger {
    case popover
    case push
    case custom
}

@objc public enum NITCouponListViewControllerCouponBackground: NSInteger {
    case normalBorders
    case jaggedBorders
}

public class NITCouponListViewController: NITBaseViewController, UITableViewDataSource, UITableViewDelegate {
    var nearManager: NITManager
    var coupons: [NITCoupon]?
    var isLoading = false
    @objc public var noContentView: UIView?
    var refreshControl: UIRefreshControl?

    @IBOutlet weak var tableView: UITableView!

    @objc public var presentCoupon = NITCouponListViewControllerPresentCoupon.push
    
    @objc public var includeValidCoupons = true
    @objc public var includeInactiveCoupons = true
    @objc public var includeExpiredCoupons = false
    @objc public var includeRedeemedCoupons = false
    
    @objc public var couponBackground = NITCouponListViewControllerCouponBackground.jaggedBorders

    @objc public var iconPlaceholder: UIImage!
    @objc public var jaggedBackground: UIImage!

    @objc public var validColor = NITUIAppearance.sharedInstance.nearGreen()
    @objc public var titleValidColor = NITUIAppearance.sharedInstance.nearGrey()
    @objc public var valueValidColor = NITUIAppearance.sharedInstance.nearBlack()
    @objc public var expiredColor = NITUIAppearance.sharedInstance.nearRed()
    @objc public var titleExpiredColor = NITUIAppearance.sharedInstance.nearGrey()
    @objc public var valueExpiredColor = NITUIAppearance.sharedInstance.nearBlack()
    @objc public var disabledColor = NITUIAppearance.sharedInstance.nearGrey()
    @objc public var titleDisabledColor = NITUIAppearance.sharedInstance.nearGrey()
    @objc public var valueDisabledColor = NITUIAppearance.sharedInstance.nearBlack()
    
    let defaultEmptyListFont = UIFont.italicSystemFont(ofSize: 16.0)
    @objc public var emptyListFont: UIFont?
    
    let defaultExpiredFont = UIFont.italicSystemFont(ofSize: 12.0)
    @objc public var expiredFont: UIFont?
    
    let defaultDisabledFont = UIFont.italicSystemFont(ofSize: 12.0)
    @objc public var disabledFont: UIFont?
    
    let defaultValidFont = UIFont.systemFont(ofSize: 12.0)
    @objc public var validFont: UIFont?
    
    let defaultTitleFont = UIFont.systemFont(ofSize: 16.0)
    @objc public var titleFont: UIFont?
    
    let defaultTitleDisabledFont = UIFont.systemFont(ofSize: 16.0)
    @objc public var titleDisabledFont: UIFont?
    
    let defaultTitleExpiredFont = UIFont.systemFont(ofSize: 16.0)
    @objc public var titleExpiredFont: UIFont?
    
    let defaultValueFont = UIFont.boldSystemFont(ofSize: 20.0)
    @objc public var valueFont: UIFont?
    
    let defaultValueDisabledFont = UIFont.systemFont(ofSize: 20.0)
    @objc public var valueDisabledFont: UIFont?
    
    let defaultValueExpiredFont = UIFont.boldSystemFont(ofSize: 20.0)
    @objc public var valueExpiredFont: UIFont?

    @objc public var expiredText: String!
    @objc public var disabledText: String!
    @objc public var validText: String!
    @objc public var redeemedText: String!
    @objc public var noCoupons: String!

    @objc public var couponViewControllerConfiguration: ((NITCouponViewController) -> Void)?

    @objc public convenience init () {
        self.init(manager: nil)
    }

    init(manager: NITManager?) {
        self.nearManager = manager ?? NITManager.default()
        let bundle = Bundle.NITBundle(for: NITCouponListViewController.self)
        super.init(nibName: "NITCouponListViewController", bundle: bundle)
        setupDefaultElements()
    }

    public required init?(coder aDecoder: NSCoder) {
        self.nearManager = NITManager.default()
        super.init(coder: aDecoder)
        let bundle = Bundle.NITBundle(for: NITCouponListViewController.self)
        bundle.loadNibNamed("NITCouponListViewController", owner: self, options: nil)
    }

    @objc public func show() {
        show(fromViewController: nil, title: nil)
    }
    @objc public func show(title: String? = nil) {
        show(fromViewController: nil, title: title)
    }

    @objc public func show(fromViewController: UIViewController? = nil, title: String? = nil) {
        guard let fromViewController = fromViewController ?? UIApplication.shared.keyWindow?.currentController() else {
            NSLog("WARNING: The app has no view hierarchy yet! If you are showing our viewController inside viewDidLoad(), you should move it to viewDidAppear().")
            return
        }
        
        let navigation = UINavigationController.init(rootViewController: self)
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .done,
                                                                target: self,
                                                                action: #selector(self.onDone))
        
        if let title = title {
            self.title = title
        }
        
        fromViewController.present(navigation, animated: true, completion: nil)
    }
    
    @objc public func show(navigationController: UINavigationController) {
        show(navigationController: navigationController, title: nil)
    }

    @objc public func show(navigationController: UINavigationController, title: String? = nil) {
        if let title = title {
            self.title = title
        }
        navigationController.pushViewController(self, animated: true)
    }

    @objc func onDone() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @objc public func refreshList() {
        refreshCoupons()
    }

    func setupDefaultElements() {
        let bundle = Bundle.NITBundle(for: NITCouponListViewController.self)
        iconPlaceholder = UIImage(named: "couponPlaceholder", in: bundle, compatibleWith: nil)
        jaggedBackground = UIImage(named: "jaggedCouponBg", in: bundle, compatibleWith: nil)

        redeemedText = "nearit_ui_coupon_list_redeemed_text".nearUILocalized
        expiredText = NSLocalizedString("Coupon list: expired coupon", tableName: nil, bundle: bundle, value: "Expired coupon", comment: "Coupon list: expired coupon")
        disabledText = NSLocalizedString("Coupon list: inactive coupon", tableName: nil, bundle: bundle, value: "Inactive coupon", comment: "Coupon list: inactive coupon")
        validText = NSLocalizedString("Coupon list: valid coupon", tableName: nil, bundle: bundle, value: "Valid coupon", comment: "Coupon list: valid coupon")
        noCoupons = NSLocalizedString( "Coupon list: no coupons", tableName: nil, bundle: bundle, value: "No coupons available", comment: "Coupon list: no coupons")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        showNoContentViewIfAvailable()
        setupUI()
        refreshCoupons()
    }

    internal func setupUI() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(self.refreshControl(_:)), for: .valueChanged)
        if let refreshControl = refreshControl {
            if #available(iOS 10.0, *) {
                tableView.refreshControl = refreshControl
            } else {
                tableView.addSubview(refreshControl)
            }
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        let bundle = Bundle.NITBundle(for: NITCouponCell.self)
        let nib = UINib.init(nibName: "NITCouponCell", bundle: bundle)
        tableView.register(nib, forCellReuseIdentifier: "coupon")
    }

    internal func refreshCoupons() {
        isLoading = true
        tableView.setContentOffset(CGPoint.init(x: 0.0, y: -60.0), animated: true)
        refreshControl?.beginRefreshing()
        nearManager.coupons { [weak self](coupons: [NITCoupon]?, error: Error?) in
            if error == nil {
                DispatchQueue.main.async {
                    guard let wself = self else { return }
                    wself.isLoading = false
                    let coupons = coupons ?? []
                    wself.coupons = coupons.filter { (coupon: NITCoupon) -> Bool in
                        wself.itemCanBeShown(coupon)
//                        if wself.filterRedeemed == .hide && coupon.isRedeemed { return false }
//                        return wself.filterOption.filter(coupon.status)
                    }
                    if let coupons = wself.coupons {
                        if coupons.count == 0 {
                            wself.showNoContentViewIfAvailable()
                        } else {
                            wself.showNoContentViewIfAvailable(false)
                        }
                    } else {
                        wself.showNoContentViewIfAvailable()
                    }
                    wself.tableView.reloadData()
                }
            } else {
                DispatchQueue.main.async {
                    self?.showNoContentViewIfAvailable()
                }
            }
            DispatchQueue.main.async {
                self?.refreshControl?.endRefreshing()
            }
        }
    }
    
    private func itemCanBeShown(_ item: NITCoupon) -> Bool {
        switch item.status {
        case .expired:
            return includeExpiredCoupons
        case .inactive:
            return includeInactiveCoupons
        case .redeemed:
            return includeRedeemedCoupons
        case .valid:
            return includeValidCoupons
        }
    }
    
    @objc func refreshControl(_ refreshControl: UIRefreshControl) {
        refreshCoupons()
    }
    
    func showNoContentViewIfAvailable(_ show: Bool = true) {
        if let noContentView = noContentView {
            if show && noContentView.superview == nil {
                noContentView.translatesAutoresizingMaskIntoConstraints = false
                noContentView.isUserInteractionEnabled = false
                view.insertSubview(noContentView, at: 0)
                noContentView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
                noContentView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
                noContentView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
                noContentView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            } else if !show {
                noContentView.removeFromSuperview()
            }
        }
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    public func numberOfSections(in tableView: UITableView) -> Int {
        return (coupons ?? []).count
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 14.0 : 7.0
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView.init()
        view.backgroundColor = .clear
        return view
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "coupon", for: indexPath)

        if let cell = cell as? NITCouponCell {
            cell.backgroundColor = .clear
            
            if couponBackground == .jaggedBorders {
                cell.backgroundView = UIImageView.init(image: jaggedBackground)
                cell.selectedBackgroundView = UIImageView.init(image: jaggedBackground.alpha(0.5))
            } else {
                cell.clipsToBounds = false
                cell.contentView.backgroundColor = .white
                cell.contentView.layer.cornerRadius = 5
                cell.contentView.layer.shadowOffset = CGSize(width: 0, height: 1)
                cell.contentView.layer.shadowColor = UIColor.black.cgColor
                cell.contentView.layer.shadowRadius = 5
                cell.contentView.layer.shadowOpacity = 0.15
            }
            
            if let coupons = coupons, coupons.count > 0 {
                let coupon = coupons[indexPath.section]

                cell.name.text = coupon.title
                cell.value.text = coupon.value
                cell.icon.image = iconPlaceholder

                switch coupon.status {
                case .inactive:
                    cell.status.text = disabledText
                    cell.status.textColor = disabledColor
                    cell.status.font = getDisabledFont()
                    cell.name.font = getTitleDisabledFont()
                    cell.name.textColor = titleDisabledColor
                    cell.value.font = getValueDisabledFont()
                    cell.value.textColor = valueDisabledColor
                case .valid:
                    cell.status.text = validText
                    cell.status.textColor = validColor
                    cell.status.font = getValidFont()
                    cell.name.font = getTitleFont()
                    cell.name.textColor = titleValidColor
                    cell.value.font = getValueFont()
                    cell.value.textColor = valueValidColor
                case .expired:
                    cell.status.text = expiredText
                    cell.status.textColor = expiredColor
                    cell.status.font = getExpiredFont()
                    cell.name.font = getTitleExpiredFont()
                    cell.name.textColor = titleExpiredColor
                    cell.value.font = getValueExpiredFont()
                    cell.value.textColor = valueExpiredColor
                case .redeemed:
                    cell.status.text = redeemedText
                    cell.status.textColor = expiredColor
                    cell.status.font = getExpiredFont()
                    cell.name.font = getTitleExpiredFont()
                    cell.name.textColor = titleExpiredColor
                    cell.value.font = getValueExpiredFont()
                    cell.value.textColor = valueExpiredColor
                }

                if let url = coupon.icon?.smallSizeURL() {
                    cell.applyImage(fromURL: url, imageDownloader: NITImageDownloader.sharedInstance)
                } else {
                    cell.icon.image = self.iconPlaceholder
                }

            } else {
                // TODO this appears to not be called anymore, if that's true, away with it!
                if isLoading {
                    cell.setLoading()
                } else {
                    cell.setMessage(noCoupons, color: NITUIAppearance.sharedInstance.nearGrey(), font: getEmptyListFont())
                }
            }
        }

        return cell
    }
    
    //  FONTS
    
    private func getEmptyListFont() -> UIFont {
        if let emptyListFont = self.emptyListFont {
            return emptyListFont
        } else {
            if let italicFont = NITUIAppearance.sharedInstance.italicFontName {
                return UIFont.init(name: italicFont, size: defaultEmptyListFont.pointSize) ?? defaultEmptyListFont
            }
            return defaultEmptyListFont
        }
    }
    
    private func getDisabledFont() -> UIFont {
        if let disabledFont = self.disabledFont {
            return disabledFont
        }
        if let italicFont = NITUIAppearance.sharedInstance.italicFontName {
            return UIFont.init(name: italicFont, size: defaultDisabledFont.pointSize) ?? defaultDisabledFont
        }
        return defaultDisabledFont
    }
    
    private func getTitleDisabledFont() -> UIFont {
        if let titleDisabledFont = self.titleDisabledFont {
            return titleDisabledFont
        }
        if let regularFont = NITUIAppearance.sharedInstance.regularFontName {
            return UIFont.init(name: regularFont, size: defaultTitleDisabledFont.pointSize) ?? defaultTitleDisabledFont
        }
        return defaultTitleDisabledFont
    }
    
    private func getValueDisabledFont() -> UIFont {
        if let valueDisabledFont = self.valueDisabledFont {
            return valueDisabledFont
        }
        if let regularFont = NITUIAppearance.sharedInstance.regularFontName {
            return UIFont.init(name: regularFont, size: defaultValueDisabledFont.pointSize) ?? defaultValueDisabledFont
        }
        return defaultValueDisabledFont
    }
    
    private func getExpiredFont() -> UIFont {
        if let expiredFont = self.expiredFont {
            return expiredFont
        }
        if let italicFont = NITUIAppearance.sharedInstance.italicFontName {
            return UIFont.init(name: italicFont, size: defaultExpiredFont.pointSize) ?? defaultExpiredFont
        }
        return defaultExpiredFont
    }
    
    private func getTitleExpiredFont() -> UIFont {
        if let titleExpiredFont = self.titleExpiredFont {
            return titleExpiredFont
        }
        if let regularFont = NITUIAppearance.sharedInstance.regularFontName {
            return UIFont.init(name: regularFont, size: defaultTitleExpiredFont.pointSize) ?? defaultTitleExpiredFont
        }
        return defaultTitleExpiredFont
    }
    
    private func getValueExpiredFont() -> UIFont {
        if let valueExpiredFont = self.valueExpiredFont {
            return valueExpiredFont
        }
        if let regularFont = NITUIAppearance.sharedInstance.regularFontName {
            return UIFont.init(name: regularFont, size: defaultValueExpiredFont.pointSize) ?? defaultValueExpiredFont
        }
        return defaultValueExpiredFont
    }
    
    private func getValidFont() -> UIFont {
        if let validFont = self.validFont {
            return validFont
        }
        if let italicFont = NITUIAppearance.sharedInstance.italicFontName {
            return UIFont.init(name: italicFont, size: defaultValidFont.pointSize) ?? defaultValidFont
        }
        return defaultValidFont
    }
    
    private func getTitleFont() -> UIFont {
        if let titleFont = self.titleFont {
            return titleFont
        }
        if let regularFont = NITUIAppearance.sharedInstance.regularFontName {
            return UIFont.init(name: regularFont, size: defaultTitleFont.pointSize) ?? defaultTitleFont
        }
        return defaultTitleFont
    }
    
    private func getValueFont() -> UIFont {
        if let valueFont = self.valueFont {
            return valueFont
        }
        if let regularFont = NITUIAppearance.sharedInstance.regularFontName {
            return UIFont.init(name: regularFont, size: defaultValueFont.pointSize) ?? defaultValueFont
        }
        return defaultValueFont
    }
    
    public func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        //  add alpha on card
        cell?.alpha = 0.5
        if couponBackground == .normalBorders {
            cell?.contentView.backgroundColor = .white
        }
    }
    
    public func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        //  restore alpha on card
        cell?.alpha = 1
        if couponBackground == .normalBorders {
            cell?.contentView.backgroundColor = .white
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let coupons = coupons else { return }
        if coupons.count == 0 {
            return
        }
        let coupon = coupons[indexPath.section]
        let couponController = NITCouponViewController.init(coupon: coupon)
        if let couponViewControllerConfiguration = couponViewControllerConfiguration {
            couponViewControllerConfiguration(couponController)
        }
        switch presentCoupon {
        case .popover:
            couponController.show()
        case .push:
            couponController.show(navigationController: navigationController!)
        case .custom: ()
        }
    }
}

extension UIImage {
    func alpha(_ value: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: value)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}
