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

    @objc public enum CFAlertControllerContentPosition : Int {
        case middle = 0
        case full
    }

    // Background
    public var backgroundStyle = CFAlertControllerBackgroundStyle.plain {
        didSet  {
            if isViewLoaded {
                applyBackgroundStyle()
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

    public var contentPosition = CFAlertControllerContentPosition.middle {
        didSet  {
            if isViewLoaded {
                applyBackgroundStyle()
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
    fileprivate var offset : CGFloat = 0
    fileprivate var keyboardVisibleHeight : CGFloat = 0
    fileprivate var keyboardIsVisible = false

    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    @IBOutlet var containerSideMarginConstraints: [NSLayoutConstraint]!
    @IBOutlet var containerSideConstraints: [NSLayoutConstraint]!

    @IBOutlet weak var containerBottomMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerTopMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var constraintAdditionalYTop: NSLayoutConstraint!
    @IBOutlet weak var centerYConstraint: NSLayoutConstraint!

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

        applyBackgroundStyle()
        
        offset = bottomConstraint.constant

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

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
        let bundle = Bundle.NITBundle(for: NITDialogController.self)
        self.init(nibName: "NITDialogController", bundle: bundle)

        self.viewController = viewController
        
        if let baseViewController = viewController as? NITBaseViewController {
            baseViewController.dialogController = self
            isEnableTapToClose = baseViewController.isEnableTapToClose
        }

        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "contentSize") {
            // Update Container View Frame Without Animation
            updateContainerViewFrame(withAnimation: false)
        }
    }
    
    internal func updateContainerViewFrame(withAnimation shouldAnimate: Bool) {
        
        let animate: (() -> Void)? = {() -> Void in
            
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
                UIView.performWithoutAnimation {
                    animate!()
                }
            }
        })
    }
    
    func dismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    func tapOutside(_ gesture: UITapGestureRecognizer) {
        if !keyboardIsVisible {
            if isEnableTapToClose {
                dismiss()
            }
        } else {
            view.endEditing(true)
        }
    }

    func applyBackgroundStyle() {
        switch backgroundStyle {
        case .blur:
            backgroundColor = .clear
            backgroundBlurView?.alpha = 1.0
        case .plain:
            backgroundColor = backgroundColor ?? .nearDialogBackground
            backgroundBlurView?.alpha = 0.0
        }

        switch contentPosition {
        case .middle:
            constraintAdditionalYTop.isActive = false
            centerYConstraint.isActive = true
        case .full:
            constraintAdditionalYTop.isActive = true
            centerYConstraint.isActive = false
            NSLayoutConstraint.deactivate(containerSideMarginConstraints)
            NSLayoutConstraint.activate(containerSideConstraints)
            viewController.view.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
            containerBottomMarginConstraint.constant = 0
            containerTopMarginConstraint.constant = 0
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

// Keyboard extension is based code from
// https://github.com/xtrinch/KeyboardLayoutHelper

extension NITDialogController {

    func keyboardWillShowNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let frameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                let frame = frameValue.cgRectValue
                keyboardVisibleHeight = frame.size.height
            }

            self.updateConstant()
            switch (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber, userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber) {
            case let (.some(duration), .some(curve)):

                let options = UIViewAnimationOptions(rawValue: curve.uintValue)

                UIView.animate(
                    withDuration: TimeInterval(duration.doubleValue),
                    delay: 0,
                    options: options,
                    animations: {
                        UIApplication.shared.keyWindow?.layoutIfNeeded()
                        return
                }, completion: { finished in
                })
            default:

                break
            }
        }
        keyboardIsVisible = true
    }

    func keyboardWillHideNotification(notification: NSNotification) {
        keyboardVisibleHeight = 0
        keyboardIsVisible = false
        self.updateConstant()

        if let userInfo = notification.userInfo {

            switch (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber, userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber) {
            case let (.some(duration), .some(curve)):

                let options = UIViewAnimationOptions(rawValue: curve.uintValue)

                UIView.animate(
                    withDuration: TimeInterval(duration.doubleValue),
                    delay: 0,
                    options: options,
                    animations: {
                        UIApplication.shared.keyWindow?.layoutIfNeeded()
                        return
                }, completion: { finished in
                })
            default:
                break
            }
        }
    }

    func updateConstant() {
        bottomConstraint.constant = offset + keyboardVisibleHeight
    }
}
