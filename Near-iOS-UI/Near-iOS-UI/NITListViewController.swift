//
//  NITListViewController.swift
//  NeariOSUI
//
//  Created by Nicola Ferruzzi on 13/11/2017.
//  Copyright © 2017 Near. All rights reserved.
//

import UIKit
import NearITSDK

@objc public enum NITListViewControllerPresentCoupon: NSInteger {
    case popover
    case push
}

@objc public enum NITListViewControllerFilterOptions: NSInteger {
    case valid = 0b001
    case expired = 0b010
    case disabled = 0b100
    case all = 0b111

    fileprivate func filter(_ status: NITCouponUIStatus) -> Bool {
        switch status {
        case .disabled:
            return (rawValue & NITListViewControllerFilterOptions.disabled.rawValue) != 0
        case .expired:
            return (rawValue & NITListViewControllerFilterOptions.expired.rawValue) != 0
        case .valid:
            return (rawValue & NITListViewControllerFilterOptions.valid.rawValue) != 0
        }
    }
}

@objc public enum NITListViewControllerFilterRedeemed: NSInteger {
    case hide
    case show
}

public class NITListViewController: NITBaseViewController, UITableViewDataSource, UITableViewDelegate {
    var nearManager: NITManager
    var coupons: [NITCoupon]?
    var isLoading = false

    @IBOutlet weak var tableView: UITableView!

    public var presentCoupon = NITListViewControllerPresentCoupon.push
    public var filterOption = NITListViewControllerFilterOptions.all
    public var filterRedeemed = NITListViewControllerFilterRedeemed.hide

    public var iconPlaceholder: UIImage!

    public var expiredText = NSLocalizedString("Expired coupon", comment: "Coupon list: expired coupon")
    public var expiredColor = UIColor.nearCouponExpired
    public var expiredFont = UIFont.italicSystemFont(ofSize: 12.0)

    public var disabledText = NSLocalizedString("Inactive coupon", comment: "Coupon list: inactive coupon")
    public var disabledColor = UIColor.nearCouponDisabled
    public var disabledFont = UIFont.italicSystemFont(ofSize: 12.0)

    public var validText = NSLocalizedString("Valid coupon", comment: "Coupon list: valid coupon ")
    public var validColor = UIColor.nearCouponValid
    public var validFont = UIFont.systemFont(ofSize: 12.0)

    public var titleFont = UIFont.boldSystemFont(ofSize: 16.0)
    public var titleColor = UIColor.nearBlack
    public var titleDisabledFont = UIFont.systemFont(ofSize: 16.0)
    public var titleDisabledColor = UIColor.nearCouponListGray
    public var titleExpiredFont = UIFont.boldSystemFont(ofSize: 16.0)
    public var titleExpiredColor = UIColor.nearCouponListGray

    public var valueFont = UIFont.boldSystemFont(ofSize: 20.0)
    public var valueColor = UIColor.nearBlack
    public var valueDisabledFont = UIFont.systemFont(ofSize: 16.0)
    public var valueDisabledColor = UIColor.nearCouponListGray
    public var valueExpiredFont = UIFont.boldSystemFont(ofSize: 16.0)
    public var valueExpiredColor = UIColor.nearCouponListGray

    public var noCoupons = NSLocalizedString("No coupons available", comment: "Coupon list: no coupons")

    public var cellBackground: UIImage!
    public var selectedCellBackground:  UIImage!

    public init(manager: NITManager = NITManager.default()) {
        self.nearManager = manager
        let bundle = Bundle(for: NITListViewController.self)
        super.init(nibName: "NITListViewController", bundle: bundle)
        setupDefaultElements()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func show() {
        self.show(configureDialog: nil)
    }

    public func show(configureDialog: ((_ dialogController: NITDialogController) -> ())? = nil ) {
        if let viewController = UIApplication.shared.keyWindow?.currentController() {
            self.show(fromViewController: viewController)
        }
    }

    public func show(fromViewController: UIViewController) {
        let navigation = UINavigationController.init(rootViewController: self)
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .done,
                                                                target: self,
                                                                action: #selector(self.onDone))
        fromViewController.present(navigation, animated: true, completion: nil)
    }

    @objc func onDone() {
        navigationController?.dismiss(animated: true, completion: nil)
    }

    public func show(from navigationController: UINavigationController) {
        navigationController.pushViewController(self, animated: true)
    }

    func setupDefaultElements() {
        let bundle = Bundle(for: NITListViewController.self)
        iconPlaceholder = UIImage(named: "couponPlaceholder", in: bundle, compatibleWith: nil)
        cellBackground = UIImage(named: "cell", in: bundle, compatibleWith: nil)
        selectedCellBackground = UIImage(named: "selectedCell", in: bundle, compatibleWith: nil)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        refreshCoupons()
    }

    internal func setupUI() {
        tableView.dataSource = self
        tableView.delegate = self
        let bundle = Bundle(for: NITCouponCell.self)
        let nib = UINib.init(nibName: "NITCouponCell", bundle: bundle)
        tableView.register(nib, forCellReuseIdentifier: "coupon")
    }

    internal func refreshCoupons() {
        isLoading = true
        nearManager.coupons { [weak self](coupons: [NITCoupon]?, error: Error?) in
            if let coupons = coupons {
                DispatchQueue.main.async {
                    guard let wself = self else { return }
                    wself.isLoading = false
                    wself.coupons = coupons.filter { (coupon: NITCoupon) -> Bool in
                        if wself.filterRedeemed == .hide && coupon.isRedeemed { return false }
                        return wself.filterOption.filter(coupon.status)
                    }
                    wself.tableView.reloadData()
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    self?.refreshCoupons()
                }
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
            cell.backgroundView = UIImageView.init(image: cellBackground)
            cell.selectedBackgroundView = UIImageView.init(image: selectedCellBackground)

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

                cell.applyImage(fromURL: coupon.icon.smallSizeURL())

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

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let coupons = coupons else { return }
        let coupon = coupons[indexPath.section]
        let couponController = NITCouponViewController.init(coupon: coupon)
        switch presentCoupon {
        case .popover:
            couponController.show()
        case .push:
            couponController.show(from: navigationController!)
        }
    }

}

