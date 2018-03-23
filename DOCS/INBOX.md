# NearIt-UI for notification inbox

Showing the history of the user notifications and content, is a common feature of apps integrated with NearIT. With NearIt-UI you can use a view controller that automatically fetches and displays notifications and content ordered by received date.

## Basic example

With these few lines of code

Swift version
```swift
let vc = NITInboxListViewController()
vc.show()
```

Objc version
```objc
NITInboxListViewController *vc = [[NITInboxListViewController alloc] init];
[vc show];
```

Optionally, you can display the content in your `UINavigationController`:

Swift version
```swift
// ...
let vc = NITInboxListViewController(content: content)
vc.show(navigationController: navigationController!)
```

Objc version
```Objc
// ...
NITInboxListViewController *vc = [[NITInboxListViewController alloc] initWithContent:content];
[vc showWithNavigationController:self.navigationController];
```

Inbox inlcudes all the near contents except for the coupons.

You can filter some of the inbox content, you can exclude:
* Custom JSONs
* Feedbacks