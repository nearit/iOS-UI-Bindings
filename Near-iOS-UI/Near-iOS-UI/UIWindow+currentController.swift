//
//  UIWindow+currentController.swift
//  NeariOSUI
//
//  Created by Nicola Ferruzzi on 02/10/2017.
//  Copyright © 2017 Near. All rights reserved.
//

import UIKit

extension UIWindow {

    func currentController() -> UIViewController? {
        if let rootViewController: UIViewController = self.rootViewController {
            return UIWindow.getCurrentControllerFrom(viewController: rootViewController)
        }
        return nil
    }

    class func getCurrentControllerFrom(viewController: UIViewController) -> UIViewController? {
        switch viewController {
        case is UINavigationController:
            if let navigationController = viewController as? UINavigationController {
                let next = navigationController.visibleViewController!
                return UIWindow.getCurrentControllerFrom(viewController: next)
            }

        case is UITabBarController:
            if let tabBarController = viewController as? UITabBarController {
                let next = tabBarController.selectedViewController!
                return UIWindow.getCurrentControllerFrom(viewController: next)
            }

        default:
            if let presentedViewController = viewController.presentedViewController {
                if let presentedViewController2 = presentedViewController.presentedViewController {
                    return UIWindow.getCurrentControllerFrom(viewController: presentedViewController2)
                }
            }
            return viewController
        }
        return nil
    }
}

