//
//  NITNotificationHistoryViewController.swift
//  NearUIBinding
//
//  Created by francesco.leoni on 23/02/18.
//  Copyright © 2018 Near. All rights reserved.
//

import UIKit
import NearITSDK

public protocol NITNotificationHistoryViewControllerDelegate: class {
    func historyViewController(_ viewController: NITNotificationHistoryViewController, willShowViewController: UIViewController)
}

public class NITNotificationHistoryViewController: NITBaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var refreshControl: UIRefreshControl?
    
    var selectedCellBackground: UIView!
    
    @objc public var includeCustomJson = false
    @objc public var includeCoupons = true
    @objc public var includeFeedbacks = true
    
    var nearManager: NITManager
    var items: [NITHistoryItem]?
    let dateFormatter = DateFormatter()
    
    @objc public var noContentView: UIView?
    @objc public var unreadColor: UIColor?
    public var delegate: NITNotificationHistoryViewControllerDelegate?
    
    @objc public convenience init () {
        self.init(manager: NITManager.default())
    }
    
    init(manager: NITManager = NITManager.default()) {
        self.nearManager = manager
        let bundle = Bundle.NITBundle(for: NITCouponListViewController.self)
        super.init(nibName: "NITNotificationHistoryViewController", bundle: bundle)
        //setupDefaultElements()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(NITNotificationHistoryViewController.refreshControl(_:)), for: .valueChanged)
        if let refreshControl = refreshControl {
            if #available(iOS 10.0, *) {
                tableView.refreshControl = refreshControl
            } else {
                tableView.addSubview(refreshControl)
            }
        }
        
        showNoContentViewIfAvailable()
        setupUI()
        setupDefaultElements()
        refreshHistory()
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupUI() {
        tableView.dataSource = self
        tableView.delegate = self
        let bundle = Bundle.NITBundle(for: NITNotificationCell.self)
        let nib = UINib.init(nibName: "NITNotificationCell", bundle: bundle)
        tableView.register(nib, forCellReuseIdentifier: "history")
    }
    
    func setupDefaultElements() {
        selectedCellBackground = UIView(frame: CGRect.zero)
        selectedCellBackground.layer.cornerRadius = 5.0
    }
    
    func refreshHistory() {
        refreshControl?.beginRefreshing()
        nearManager.history {[weak self] (items, error) in
            if let _ = error {
                self?.showNoContentViewIfAvailable()
            } else {
                var filteredItems = [NITHistoryItem]()
                for item in items ?? [] {
                    if let _ = item.reactionBundle as? NITSimpleNotification {
                        item.read = true
                    } else if let _ = item.reactionBundle as? NITCustomJSON {
                        if let includeCustomJson = self?.includeCustomJson {
                            if !includeCustomJson {
                                continue
                            }
                        }
                    } else if let _ = item.reactionBundle as? NITFeedback {
                        if let includeFeedbacks = self?.includeFeedbacks {
                            if !includeFeedbacks {
                                continue
                            }
                        }
                    } else if let _ = item.reactionBundle as? NITCoupon {
                        if let includeCoupons = self?.includeCoupons {
                            if !includeCoupons {
                                continue;
                            }
                        }
                    }
                    filteredItems.append(item)
                }
                self?.items = filteredItems
                self?.refreshControl?.endRefreshing()
                self?.tableView.reloadData()
                
                if self?.items?.count == 0 {
                    self?.showNoContentViewIfAvailable()
                } else {
                    self?.showNoContentViewIfAvailable(false)
                }
            }
        }
    }
    
    @objc public func show() {
        show(fromViewController: nil)
    }
    
    @objc public func show(fromViewController: UIViewController? = nil) {
        if let fromViewController = fromViewController ?? UIApplication.shared.keyWindow?.currentController() {
            
            let navigation = UINavigationController.init(rootViewController: self)
            fromViewController.present(navigation, animated: true, completion: nil)
        }
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
    
    @objc public func refreshList() {
        refreshHistory()
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
    
    // MARK: - Refresh control
    
    @objc func refreshControl(_ refreshControl: UIRefreshControl) {
        refreshHistory()
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

extension NITNotificationHistoryViewController: UITableViewDataSource, UITableViewDelegate {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return (items ?? []).count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "history", for: indexPath)
        
        if let cell = cell as? NITNotificationCell {
            cell.backgroundColor = .clear
            cell.selectedBackgroundView = selectedCellBackground
            
            if let item = items?[indexPath.section] {
                let date = Date(timeIntervalSince1970: item.timestamp)
                cell.dateLabel.text = dateFormatter.string(from: date)
                cell.messageLabel.text = item.reactionBundle.notificationMessage
                if let color = unreadColor {
                    cell.unreadColor = color
                }
                
                if let _ = item.reactionBundle as? NITSimpleNotification {
                    cell.state = .notReadable
                } else {
                    if item.read {
                        cell.state = .read
                    } else {
                        cell.state = .unread
                    }
                }
            }
        }
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        //  add alpha on card
        let cell = tableView.cellForRow(at: indexPath)
        cell?.alpha = 0.5
        cell?.contentView.backgroundColor = .white
    }
    
    public func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        //  restore alpha on card
        let cell = tableView.cellForRow(at: indexPath)
        cell?.alpha = 1.0
        cell?.contentView.backgroundColor = .white
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = items?[indexPath.section] {
            nearManager.sendTracking(with: item.trackingInfo, event: NITRecipeOpened)
            item.read = true
            tableView.reloadRows(at: [indexPath], with: .automatic)
            
            if let feedback = item.reactionBundle as? NITFeedback {
                let feedbackVC = NITFeedbackViewController(feedback: feedback)
                delegate?.historyViewController(self, willShowViewController: feedbackVC)
                feedbackVC.show(fromViewController: self, configureDialog: nil)
            } else if let content = item.reactionBundle as? NITContent {
              let contentVC = NITContentViewController(content: content, trackingInfo: item.trackingInfo)
                delegate?.historyViewController(self, willShowViewController: contentVC)
                contentVC.show(fromViewController: self, configureDialog: nil)
            } else if let coupon = item.reactionBundle as? NITCoupon {
                let couponVC = NITCouponViewController(coupon: coupon)
                delegate?.historyViewController(self, willShowViewController: couponVC)
                couponVC.show(fromViewController: self, configureDialog: nil)
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect.zero)
        view.backgroundColor = .clear
        return view
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
}
