# NearIt-UI for coupon list

Providing a list of coupons earned by the user is a common feature of apps that integrate NearIT.
With NearIt-UI you can show an view controller that automatically fetches and displays coupons with our proposed sorting.

#### Introduction

To understand the examples in this section it is important to know how NearIT coupons work.
A coupon can have a date from which an user can redeem it and an expiration date. At a certain date a coupon could be in one of these states:
- valid: redeemable, not expired and not already used.
- not yet active: not yet redeemable
- expired: current date is beyond the expiration one
- redeemed: coupon code has been used
With NearIT-UI, depending on its state, a coupon will appear in a different way. 

#### Basic example 
With these few lines of code

Swift version
```swift
let vc = NITCouponListViewController()
vc.show()
```

Objc version
```objc
NITCouponListViewController *vc = [[NITCouponListViewController alloc] init];
[vc show];
```

Optionally, you can display the content in your `UINavigationController`:

Swift version
```swift
// ...
let vc = NITCouponListViewController()
vc.show(navigationController: navigationController!)
```

Objc version
```Objc
// ...
NITCouponListViewController *vc = [[NITCouponListViewController alloc] init];
[vc showWithNavigationController:self.navigationController];
```

You are able to filter the list of coupons with this options:
- valid coupons
- not yet active coupons
- expired coupons

Swift version
```swift
[...]
vc.filterOption = .disabled | .valid | .expired
vc.filterRedeemed = .show
vc.show()
```

Objc version
```objc
[...]
vc.filterOption = NITCouponListViewControllerFilterOptionsValid | NITCouponListViewControllerFilterOptionsExpired | NITCouponListViewControllerFilterOptionsDisabled;
vc.filterRedeemed = NITCouponListViewControllerFilterRedeemedShow;
[vc show];
```

<!-- ![coupon list](coupon_list.png) -->

An automatic refresh every 5 seconds is attempted if a server or network problem occurs while the coupon list is being downloaded
 
#### UI Customizations

Most aspects of the list UI can be customized, please refer to the main source code for the list of public variables.

Swift version
```
[...]
vc.valueFont = UIFont.boldSystemFont(ofSize: 30)
vc.cellBackground = UIImage.init(named: "customCell")
vc.selectedCellBackground = nil
vc.show()
```

#### Coupon presentation

Selected `coupon` can be presented either as push in the `UINavigationController` or as a pop-over.

Swift version
```swift
[...]
vc.presentCoupon = .popover
```

Objc version
```objc
[...]
vc.presentCoupon = NITCouponListViewControllerPresentCouponPopover;
```

If you need more controll over the customization of the coupon controller you can configure a custom presentation callback. Please refer to [Coupon dialog](COUPON.md) for more informations.

Swift version
```
[...]
vc.presentCoupon = .custom
vc.couponViewControllerConfiguration = { (couponVC: NITCouponViewController) -> Void in
    couponVC ...
    couponVC.show(fromViewController: nil, configureDialog: { (dialogController) in    
        dialogController.backgroundStyle = .blur
    })
}
vc.show()
```

Objc version
```
[...]
vc.presentCoupon = NITCouponListViewControllerPresentCouponCustom;
vc.couponViewControllerConfiguration = ^(NITCouponViewController *couponVC) {
    [couponVC showFromViewController:nil configureDialog:^(NITDialogController *dialogController) {
        dialogController.backgroundStyle = CFAlertControllerBackgroundStyleBlur;
    }];
};
```


