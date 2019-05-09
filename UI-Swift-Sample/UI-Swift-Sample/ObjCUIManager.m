//
//  ObjCUIManager.m
//  UI-Swift-Sample
//
//  Created by francesco.leoni on 10/11/17.
//  Copyright © 2017 Near. All rights reserved.
//

#import "ObjCUIManager.h"
@import NearUIBinding;
@import NearITSDKSwift;

static NSString *const sharedManagerLock = @"manager.lock";
static ObjCUIManager *sharedManager;

@implementation ObjCUIManager

+ (ObjCUIManager*)sharedInstance {
    @synchronized (sharedManagerLock) {
        if (!sharedManager) {
            sharedManager = [[ObjCUIManager alloc] init];
        }
    }
    
    return sharedManager;
}

- (void)showPermissiongDialog {
    NITPermissionsViewController *controller = [[NITPermissionsViewController alloc] init];
    [controller show];
}

- (void)showListOfCoupons {
    NITCouponListViewController *controller = [[NITCouponListViewController alloc] init];
    controller.filterOption = NITCouponListViewControllerFilterOptionsValid;
    [controller show];
}

- (void)installPermissionBar:(UIViewController *)vc {
    NITPermissionsView *permissionView = [[NITPermissionsView alloc] initWithFrame:CGRectZero];
    [vc.view addSubview:permissionView];

    [permissionView.leftAnchor constraintEqualToAnchor:vc.view.leftAnchor].active = TRUE;
    [permissionView.rightAnchor constraintEqualToAnchor:vc.view.rightAnchor].active = TRUE;
    if (@available(iOS 11.0, *)) {
        [permissionView.topAnchor constraintEqualToAnchor:vc.view.safeAreaLayoutGuide.topAnchor].active = TRUE;
    } else {
        [permissionView.topAnchor constraintEqualToAnchor:vc.topLayoutGuide.bottomAnchor].active = TRUE;
    }
}

- (void)showContenDialog:(NITContent *)content trackingInfo:(NITTrackingInfo *)trackingInfo {
    NITContentViewController *vc = [[NITContentViewController alloc] initWithContent:content trackingInfo:trackingInfo];
    [vc showFromViewController:nil configureDialog:nil];
}

- (void)showCouponDialog:(NITCoupon *)coupon {
    NITCouponViewController *vc = [[NITCouponViewController alloc] initWithCoupon:coupon];
    [vc showFromViewController:nil configureDialog:nil];
}

- (void)showFeedbackDialog:(NITFeedback *)feedback {
    NITFeedbackViewController *vc = [[NITFeedbackViewController alloc] initWithFeedback:feedback];
    [vc showFromViewController:nil configureDialog:^(NITDialogController *dialog) {
        dialog.backgroundStyle = CFAlertControllerBackgroundStyleBlur;
    }];
}

- (void)showHistoryWithNavigationController:(UINavigationController*)navController {
    NITNotificationHistoryViewController *historyVC = [[NITNotificationHistoryViewController alloc] init];
    historyVC.unreadColor = [UIColor colorWithRed:99.0/255.0 green:182.0/255.0 blue:1.0 alpha:1.0];
    [historyVC showWithNavigationController:navController title:@"my coupons"];
}

- (void)showHistoryWithNavigationController:(UINavigationController *)navController customNoContent:(UIView *)noContentView {
    NITNotificationHistoryViewController *historyVC = [[NITNotificationHistoryViewController alloc] init];
    historyVC.noContentView = noContentView;
    historyVC.unreadColor = [UIColor colorWithRed:99.0/255.0 green:182.0/255.0 blue:1.0 alpha:1.0];
    [historyVC showWithNavigationController:navController];
}

@end
