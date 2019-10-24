## 2.12.3 (2019-10-24)

### API Breaking Changes

* None.

### Enhancements

* You can set the button global corner radius. Only available when called from Swift.
```
// set the radius equal to half the height
NITUIAppearance.sharedInstance.globalButtonLook = .fullRound
// set a specific radius
NITUIAppearance.sharedInstance.globalButtonLook = .radiusOf(2.0)
```

### Bugfixes

* None.

## 2.12.2 (2019-09-20)

### API Breaking Changes

* None.

### Enhancements

* On iOS13, won't ask for bluetooth permissions.

### Bugfixes

* None.

## 2.12.1 (2019-06-27)

### API Breaking Changes

* None.

### Enhancements

* None

### Bugfixes

* Handle NITContent nullable fields.

## 2.12.0 (2019-06-07)

### API Breaking Changes

* None.

### Enhancements

* Compatible with 2.12.0 core library. 

### Bugfixes

* Notification center handling.

## 2.11.9 (2019-05-22)

### API Breaking Changes

* None.

### Enhancements

* Support right-to-left locales.
* Date format can be overridden.

### Bugfixes

* None.

## 2.11.8 (2019-05-09)

### API Breaking Changes

* None.

### Enhancements

* Utility method made available for Obj-C.

### Bugfixes

* None.

## 2.11.7 (2019-05-09)

### API Breaking Changes

* None.

### Enhancements

* New method for opening content dialogs immediately.
* Pass `trackingInfo` to custom JSON taps delegate method.

### Bugfixes

* None.

## 2.11.5 (2019-04-30)

### API Breaking Changes

* None.

### Enhancements

*  `NITNotificationHistoryViewController` delegate has method for detecting tap on custom JSONs.

### Bugfixes

* None.

## 2.11.5 (2019-03-15)

### API Breaking Changes

* None.

### Enhancements

* `NITCouponViewController` and `NITNotificationHistoryViewController` can be used from Interface Builder.

### Bugfixes

* None.

## 2.11.4 (2019-02-20)

### API Breaking Changes

* None.

### Enhancements

* None.

### Bugfixes

* Avoid sending empty comment for Feedback answer.

## 2.11.3 (2019-02-14)

### API Breaking Changes

* None.

### Enhancements

* Automatically track simple notifications as read when rendered in notification list.

### Bugfixes

* None.

## 2.11.2 (2019-02-13)

### API Breaking Changes

None.

### Enhancements

None.

### Bugfixes

* Fixed glitch on simple notifications in history list.

## 2.10.5 (2018-11-28)

### API Breaking Changes

None.

### Enhancements

None.

### Bugfixes

* Fixed glitch on notification tap from history list.
