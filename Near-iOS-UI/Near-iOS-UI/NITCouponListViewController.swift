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

@objc public enum NITCouponListViewControllerFilterOptions: NSInteger {
    case none = 0b000
    case valid = 0b001
    case expired = 0b010
    case validAndExpired =  0b011
    case disabled = 0b100
    case validAndDisabled = 0b101
    case expiredAndDisabled = 0b110
    case all = 0b111

    fileprivate func filter(_ status: NITCouponUIStatus) -> Bool {
        switch status {
        case .disabled:
            return contains(NITCouponListViewControllerFilterOptions.disabled)
        case .expired:
            return contains(NITCouponListViewControllerFilterOptions.expired)
        case .valid:
            return contains(NITCouponListViewControllerFilterOptions.valid)
        }
    }

    static public func |(lhs: NITCouponListViewControllerFilterOptions, rhs: NITCouponListViewControllerFilterOptions) -> NITCouponListViewControllerFilterOptions {
        let or = lhs.rawValue | rhs.rawValue
        return NITCouponListViewControllerFilterOptions(rawValue: or)!
    }

    public func contains(_ lhs: NITCouponListViewControllerFilterOptions) -> Bool {
        return (rawValue & lhs.rawValue) != 0
    }

}

@objc public enum NITCouponListViewControllerFilterRedeemed: NSInteger {
    case hide
    case show
}

public class NITCouponListViewController: NITBaseViewController, UITableViewDataSource, UITableViewDelegate {
    var nearManager: NITManager
    var coupons: [NITCoupon]?
    var isLoading = false
    @objc public var noContentView: UIView?
    var refreshControl: UIRefreshControl?

    @IBOutlet weak var tableView: UITableView!

    @objc public var presentCoupon = NITCouponListViewControllerPresentCoupon.push
    @objc public var filterOption = NITCouponListViewControllerFilterOptions.all
    @objc public var filterRedeemed = NITCouponListViewControllerFilterRedeemed.hide
    
    @objc public var couponBackground = NITCouponListViewControllerCouponBackground.jaggedBorders

    @objc public var iconPlaceholder: UIImage!
    @objc public var jaggedBackground: UIImage!

    @objc public var expiredColor = UIColor.nearCouponExpired
    @objc public var expiredFont = UIFont.italicSystemFont(ofSize: 12.0)

    @objc public var disabledColor = UIColor.nearCouponDisabled
    @objc public var disabledFont = UIFont.italicSystemFont(ofSize: 12.0)

    @objc public var validColor = UIColor.nearCouponValid
    @objc public var validFont = UIFont.systemFont(ofSize: 12.0)

    @objc public var titleFont = UIFont.systemFont(ofSize: 16.0)
    @objc public var titleColor = UIColor.nearCouponTitleGray
    @objc public var titleDisabledFont = UIFont.systemFont(ofSize: 16.0)
    @objc public var titleDisabledColor = UIColor.nearCouponTitleGray
    @objc public var titleExpiredFont = UIFont.systemFont(ofSize: 16.0)
    @objc public var titleExpiredColor = UIColor.nearCouponTitleGray

    @objc public var valueFont = UIFont.boldSystemFont(ofSize: 20.0)
    @objc public var valueColor = UIColor.nearBlack
    @objc public var valueDisabledFont = UIFont.systemFont(ofSize: 16.0)
    @objc public var valueDisabledColor = UIColor.nearCouponListGray
    @objc public var valueExpiredFont = UIFont.boldSystemFont(ofSize: 16.0)
    @objc public var valueExpiredColor = UIColor.nearCouponListGray

    @objc public var expiredText: String!
    @objc public var disabledText: String!
    @objc public var validText: String!
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
        fatalError("init(coder:) has not been implemented")
    }

    @objc public func show() {
        show(fromViewController: nil)
    }

    @objc public func show(fromViewController: UIViewController? = nil) {

        if let fromViewController = fromViewController ?? UIApplication.shared.keyWindow?.currentController() {

            let navigation = UINavigationController.init(rootViewController: self)
            navigationItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .done,
                                                                    target: self,
                                                                    action: #selector(self.onDone))
            fromViewController.present(navigation, animated: true, completion: nil)
        }
    }

    @objc public func show(navigationController: UINavigationController) {
        navigationController.pushViewController(self, animated: true)
    }

    @objc func onDone() {
        navigationController?.dismiss(animated: true, completion: nil)
    }

    func setupDefaultElements() {
        let bundle = Bundle.NITBundle(for: NITCouponListViewController.self)
        iconPlaceholder = UIImage(named: "couponPlaceholder", in: bundle, compatibleWith: nil)
        jaggedBackground = UIImage(named: "jaggedCouponBg", in: bundle, compatibleWith: nil)

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
        refreshControl?.beginRefreshing()
        nearManager.coupons { [weak self](coupons: [NITCoupon]?, error: Error?) in
            if error == nil {
                DispatchQueue.main.async {
                    guard let wself = self else { return }
                    wself.isLoading = false
                    let coupons = coupons ?? []
                    wself.coupons = coupons.filter { (coupon: NITCoupon) -> Bool in
                        if wself.filterRedeemed == .hide && coupon.isRedeemed { return false }
                        return wself.filterOption.filter(coupon.status)
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
    
    @objc func refreshControl(_ refreshControl: UIRefreshControl) {
        refreshCoupons()
    }
    
    func showNoContentViewIfAvailable(_ show: Bool = true) {
        if let noContentView = noContentView {
            if show && noContentView.superview == nil {
                noContentView.translatesAutoresizingMaskIntoConstraints = false
                noContentView.isUserInteractionEnabled = false
                view.addSubview(noContentView)
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
        return max((coupons ?? []).count, 1)
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
            
            if (couponBackground == .jaggedBorders) {
                cell.backgroundView = UIImageView.init(image: jaggedBackground)
                cell.selectedBackgroundView = UIImageView.init(image: jaggedBackground.alpha(0.5))
            } else {
                cell.clipsToBounds = false
                cell.contentView.backgroundColor = .white
                cell.contentView.layer.cornerRadius = 5
                cell.contentView.layer.shadowOffset = CGSize(width: 0, height: 1);
                cell.contentView.layer.shadowColor = UIColor.black.cgColor
                cell.contentView.layer.shadowRadius = 5;
                cell.contentView.layer.shadowOpacity = 0.15;
            }
            
            if let coupons = coupons, coupons.count > 0 {
                let coupon = coupons[indexPath.section]

                cell.name.text = coupon.title
                cell.value.text = coupon.value
                cell.icon.image = iconPlaceholder

                switch coupon.status {
                case .disabled:
                    cell.status.text = disabledText
                    cell.status.textColor = disabledColor
                    cell.status.font = disabledFont
                    cell.name.font = titleDisabledFont
                    cell.name.textColor = titleDisabledColor
                    cell.value.font = valueDisabledFont
                    cell.value.textColor = valueDisabledColor
                case .valid:
                    cell.status.text = validText
                    cell.status.textColor = validColor
                    cell.status.font = validFont
                    cell.name.font = titleFont
                    cell.name.textColor = titleColor
                    cell.value.font = valueFont
                    cell.value.textColor = valueColor
                case .expired:
                    cell.status.text = expiredText
                    cell.status.textColor = expiredColor
                    cell.status.font = expiredFont
                    cell.name.font = titleExpiredFont
                    cell.name.textColor = titleExpiredColor
                    cell.value.font = valueExpiredFont
                    cell.value.textColor = valueExpiredColor
                }

                if let url = coupon.icon?.smallSizeURL() {
                    cell.applyImage(fromURL: url)
                }

            } else {
                if isLoading {
                    cell.setLoading()
                } else {
                    cell.setMessage(noCoupons, color: .nearWarmGrey, font: .systemFont(ofSize: 15.0))
                }
            }
        }

        return cell
    }
    
    public func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        //  remove cell background to show the selected one
        if couponBackground == .jaggedBorders {
            cell?.backgroundView = nil
        } else {
            cell?.contentView.backgroundColor = cell?.contentView.backgroundColor?.withAlphaComponent(0.1)
        }
    }
    
    public func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        //  restore cell background
        if couponBackground == .jaggedBorders {
            cell?.backgroundView = UIImageView.init(image: jaggedBackground)
        } else {
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
    
    func alpha(_ value:CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: value)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}

