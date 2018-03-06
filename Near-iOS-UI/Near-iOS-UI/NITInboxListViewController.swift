//
//  NITInboxListViewController.swift
//  NearUIBinding
//
//  Created by francesco.leoni on 23/02/18.
//  Copyright © 2018 Near. All rights reserved.
//

import UIKit
import NearITSDK

struct NITInboxAvailableItems: OptionSet {
    let rawValue: Int
    
    static let customJSON = NITInboxAvailableItems(rawValue: 1 << 0)
    static let feedback = NITInboxAvailableItems(rawValue: 1 << 1)
    
    static let all: NITInboxAvailableItems = [.customJSON, .feedback]
}

public class NITInboxListViewController: NITBaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var refreshControl: UIRefreshControl?
    
    var selectedCellBackground: UIView!
    
    var nearManager: NITManager
    var items: [NITInboxItem]?
    let dateFormatter = DateFormatter()
    var availableItems: NITInboxAvailableItems = .all
    @objc public var noContentView: UIView?
    
    @objc public convenience init () {
        self.init(manager: NITManager.default())
    }
    
    init(manager: NITManager = NITManager.default()) {
        self.nearManager = manager
        let bundle = Bundle.NITBundle(for: NITCouponListViewController.self)
        super.init(nibName: "NITInboxListViewController", bundle: bundle)
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
        refreshControl?.addTarget(self, action: #selector(NITInboxListViewController.refreshControl(_:)), for: .valueChanged)
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
        refreshInbox()
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupUI() {
        tableView.dataSource = self
        tableView.delegate = self
        let bundle = Bundle.NITBundle(for: NITInboxCell.self)
        let nib = UINib.init(nibName: "NITInboxCell", bundle: bundle)
        tableView.register(nib, forCellReuseIdentifier: "inbox")
    }
    
    func setupDefaultElements() {
        selectedCellBackground = UIView(frame: CGRect.zero)
        selectedCellBackground.layer.cornerRadius = 5.0
    }
    
    func refreshInbox() {
        refreshControl?.beginRefreshing()
        nearManager.inbox {[weak self] (items, error) in
            if let _ = error {
                
            } else {
                var filteredItems = [NITInboxItem]()
                for item in items ?? [] {
                    if let _ = item.reactionBundle as? NITSimpleNotification {
                        item.read = true
                    } else if let _ = item.reactionBundle as? NITCustomJSON {
                        if let jsonAvailable = self?.availableItems.contains(.customJSON) {
                            if !jsonAvailable {
                                continue
                            }
                        }
                    } else if let _ = item.reactionBundle as? NITFeedback {
                        if let feedbackAvailable = self?.availableItems.contains(.feedback) {
                            if !feedbackAvailable {
                                continue
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
    
    @objc public func show(navigationController: UINavigationController) {
        navigationController.pushViewController(self, animated: true)
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
    
    // MARK: - Refresh control
    
    @objc func refreshControl(_ refreshControl: UIRefreshControl) {
        refreshInbox()
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

extension NITInboxListViewController: UITableViewDataSource, UITableViewDelegate {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return (items ?? []).count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "inbox", for: indexPath)
        
        if let cell = cell as? NITInboxCell {
            cell.backgroundColor = .clear
            cell.selectedBackgroundView = selectedCellBackground
            
            if let item = items?[indexPath.section] {
                let date = Date(timeIntervalSince1970: item.timestamp)
                cell.dateLabel.text = dateFormatter.string(from: date)
                cell.messageLabel.text = item.reactionBundle.notificationMessage
                
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
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = items?[indexPath.section] {
            nearManager.sendTracking(with: item.trackingInfo, event: NITRecipeEngaged)
            item.read = true
            tableView.reloadRows(at: [indexPath], with: .automatic)
            
            if let feedback = item.reactionBundle as? NITFeedback {
                let feedbackVC = NITFeedbackViewController(feedback: feedback)
                feedbackVC.show(fromViewController: self, configureDialog: nil)
            } else if let content = item.reactionBundle as? NITContent {
                let contentVC = NITContentViewController(content: content)
                contentVC.show(fromViewController: self, configureDialog: nil)
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
