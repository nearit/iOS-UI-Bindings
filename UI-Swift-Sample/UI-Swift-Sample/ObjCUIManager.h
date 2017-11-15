//
//  ObjCUIManager.h
//  UI-Swift-Sample
//
//  Created by francesco.leoni on 10/11/17.
//  Copyright © 2017 Near. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ObjCUIManager : NSObject

+ (ObjCUIManager*)sharedInstance;

- (void)showPermissiongDialog;
- (void)showListOfCoupons;

@end
