//
//  ObjCUIManager.h
//  UI-Swift-Sample
//
//  Created by francesco.leoni on 10/11/17.
//  Copyright © 2017 Near. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class NITContent;
@class NITCoupon;
@class NITFeedback;

@interface ObjCUIManager : NSObject

+ (ObjCUIManager*)sharedInstance;

- (void)showPermissiongDialog;
- (void)showListOfCoupons;
- (void)showContenDialog:(NITContent *)content;
- (void)showCouponDialog:(NITCoupon *)coupon;
- (void)showFeedbackDialog:(NITFeedback *)feedback;
- (void)showHistoryWithNavigationController:(UINavigationController*)navController;
- (void)showHistoryWithNavigationController:(UINavigationController*)navController customNoContent:(UIView*)noContentView;

@end
