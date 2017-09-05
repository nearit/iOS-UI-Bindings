//
//  DialogController.swift
//  Near-iOS-UI
//
//  Created by francesco.leoni on 30/08/17.
//  Copyright © 2017 Near. All rights reserved.
//

import UIKit

public class NITDialogController: UIViewController {
    
    @objc public enum CFAlertControllerBackgroundStyle : Int {
        case plain = 0
        case blur
    }
    
    // Background
    public var backgroundStyle = CFAlertControllerBackgroundStyle.plain    {
        didSet  {
            if isViewLoaded {
                // Set Background
                if backgroundStyle == .blur {
                    // Set Blur Background
                    backgroundBlurView?.alpha = 1.0
                }
                else {
                    // Display Plain Background
                    backgroundBlurView?.alpha = 0.0
                }
            }
        }
    }
    public var backgroundColor: UIColor?    {
        didSet  {
            if isViewLoaded {
                view.backgroundColor = backgroundColor
            }
        }
    }
    var isEnableTapToClose = true
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var backgroundBlurView: UIVisualEffectView?
    @IBOutlet weak var containerView: UIView!
    private var viewController: UIViewController!

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        contentView.layer.cornerRadius = 5.0
        scrollView.layer.cornerRadius = 5.0
        
        addChildViewController(viewController)
        contentView.addSubview(viewController.view)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.frame = contentView.bounds

        viewController.view.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        viewController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        viewController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        viewController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        
        viewController.didMove(toParentViewController: self)
        
        scrollView?.addObserver(self, forKeyPath: "contentSize", options: [.new, .old, .prior], context: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapOutside(_:)))
        tapGesture.delegate = self
        containerView.addGestureRecognizer(tapGesture)
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public convenience init(viewController: UIViewController) {
        // Get Current Bundle
        let bundle = Bundle(for: NITDialogController.self)
        
        // Create New Instance Of Alert Controller
        self.init(nibName: "NITDialogController", bundle: bundle)
        
        self.viewController = viewController
        
        if let baseViewController = viewController as? NITBaseViewController {
            baseViewController.dialogController = self
            isEnableTapToClose = baseViewController.isEnableTapToClose
        }
        
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "contentSize") {
            // Update Container View Frame Without Animation
            updateContainerViewFrame(withAnimation: false)
        }
    }
    
    internal func updateContainerViewFrame(withAnimation shouldAnimate: Bool) {
        
        let animate: ((_: Void) -> Void)? = {() -> Void in
            
            if let scrollView = self.scrollView   {
                
                // Update Content Size
                self.scrollHeightConstraint.constant = scrollView.contentSize.height
            }
        }
        
        DispatchQueue.main.async(execute: {() -> Void in
            if shouldAnimate {
                // Animate height changes
                UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [.curveEaseOut, .beginFromCurrentState, .allowUserInteraction], animations: {() -> Void in
                    // Animate
                    animate!()
                    // Relayout
                    self.view.layoutIfNeeded()
                }, completion: { _ in })
            }
            else {
                animate!()
            }
        })
    }
    
    func dismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    func tapOutside(_ gesture: UITapGestureRecognizer) {
        if isEnableTapToClose {
            dismiss()
        }
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

extension NITDialogController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let point = touch.location(in: self.scrollView)
        let inside = scrollView.point(inside: point, with: nil)
        return !inside
    }
}
