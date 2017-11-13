//
//  ObjCUIManager.m
//  UI-Swift-Sample
//
//  Created by francesco.leoni on 10/11/17.
//  Copyright © 2017 Near. All rights reserved.
//

#import "ObjCUIManager.h"
@import NeariOSUI;

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
    NITListViewController *controller = [[NITListViewController alloc] init];
    controller.filterOption = NITListViewControllerFilterOptionsValid;
    [controller show];
}

@end
