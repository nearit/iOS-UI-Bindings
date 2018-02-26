//
//  NITInboxListViewController.swift
//  NearUIBinding
//
//  Created by francesco.leoni on 23/02/18.
//  Copyright © 2018 Near. All rights reserved.
//

import UIKit
import NearITSDK

public class NITInboxListViewController: NITBaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var cellBackground: UIImage!
    var cellReadBackground: UIImage!
    var selectedCellBackground:  UIImage!
    
    var nearManager: NITManager
    var items: [NITInboxItem]?
    let dateFormatter = DateFormatter()
    
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
        tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0)
        
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
        let bundle = Bundle.NITBundle(for: NITCouponListViewController.self)
        cellBackground = UIImage(named: "cell", in: bundle, compatibleWith: nil)
        cellReadBackground = UIImage(named: "bgNewsSenzacontenuto", in: bundle, compatibleWith: nil)
        selectedCellBackground = UIImage(named: "selectedCell", in: bundle, compatibleWith: nil)
    }
    
    func refreshInbox() {
        nearManager.inbox {[weak self] (items, error) in
            if let _ = error {
                
            } else {
                self?.items = items
                for item in self?.items ?? [] {
                    if let _ = item.reactionBundle as? NITSimpleNotification {
                        item.read = true
                    }
                }
                self?.tableView.reloadData()
            }
        }
    }
    
    @objc public func show(navigationController: UINavigationController) {
        navigationController.pushViewController(self, animated: true)
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
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (items ?? []).count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "inbox", for: indexPath)
        
        if let cell = cell as? NITInboxCell {
            cell.backgroundColor = .clear
            
            if let item = items?[indexPath.row] {
                let date = Date(timeIntervalSince1970: item.timestamp)
                cell.dateLabel.text = dateFormatter.string(from: date)
                cell.messageLabel.text = item.reactionBundle.notificationMessage
                cell.makeBoldMessage(!item.read)
                cell.makeBoldMore(!item.read)
                
                if item.read {
                    cell.backgroundView = UIImageView.init(image: cellReadBackground)
                } else {
                    cell.backgroundView = UIImageView.init(image: cellBackground)
                    cell.selectedBackgroundView = UIImageView.init(image: selectedCellBackground)
                }
            }
        }
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = items?[indexPath.row] {
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
}
