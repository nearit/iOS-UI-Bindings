//
//  NITPermissionViewSpec.swift
//  NeariOSUITests
//
//  Created by Nicola Ferruzzi on 16/11/2017.
//  Copyright © 2017 Near. All rights reserved.
//

import Quick
import Nimble
import FBSnapshotTestCase
import Nimble_Snapshots
import UIKit
import CoreBluetooth
import CoreLocation
@testable import NearITSDK
@testable import NearUIBinding

class NITPermissionViewSpec: QuickSpec {

    override func spec() {
        var view: NITPermissionsView!
        var fakePermissionManager: FakePermissionManager!
        var fakeCBPeripheralManager: FakeCBPeripheralManager!

        describe("view") {
            beforeEach {
                fakePermissionManager = FakePermissionManager()
                fakeCBPeripheralManager = FakeCBPeripheralManager()

                view = NITPermissionsView.init(frame: .zero,
                                               permissionManager: fakePermissionManager,
                                               btManager: fakeCBPeripheralManager)
            }

            afterEach {
            }

            it("all icons are unavailables") {
                fakePermissionManager.location = false
                fakePermissionManager.notifications = false
                fakeCBPeripheralManager.bluetooth = false

                view.permissionsRequired = .all
                view.shouldRefresh()
                expect(view.permissionButton.alreadyMissing).to(contain(.blueTooth, .location, .notification))
            }

            it("location/notification icons are availables") {
                fakePermissionManager.location = true
                fakePermissionManager.notifications = true
                fakeCBPeripheralManager.bluetooth = true

                view.permissionsRequired = .all
                view.shouldRefresh()
                expect(view.permissionButton.alreadyMissing).toNot(contain(.location))
                expect(view.permissionButton.alreadyMissing).toNot(contain(.blueTooth))
                expect(view.permissionButton.alreadyMissing).toNot(contain(.notification))
            }

            it ("visible when permissions are missing") {
                fakePermissionManager.location = false
                fakePermissionManager.notifications = false
                fakeCBPeripheralManager.bluetooth = false

                let vc = UIViewController.init()
                expect(vc.view).toNot(beNil())

                vc.view.addSubview(view)
                NSLayoutConstraint.activate([
                    view.leftAnchor.constraint(equalTo: vc.view.leftAnchor),
                    view.rightAnchor.constraint(equalTo: vc.view.rightAnchor),
                    view.topAnchor.constraint(equalTo: vc.topLayoutGuide.bottomAnchor),
                    ])

                view.permissionsRequired = .all

                vc.beginAppearanceTransition(true, animated: false)
                vc.endAppearanceTransition()

                // anti debouncer
                RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))

                expect(view.frame.size.height).to(equal(CGFloat(50.0)))
            }

            it ("hidden when permissions are ok") {
                fakePermissionManager.location = true
                fakePermissionManager.notifications = true
                fakeCBPeripheralManager.bluetooth = true

                let vc = UIViewController.init()
                expect(vc.view).toNot(beNil())

                vc.view.addSubview(view)
                NSLayoutConstraint.activate([
                    view.leftAnchor.constraint(equalTo: vc.view.leftAnchor),
                    view.rightAnchor.constraint(equalTo: vc.view.rightAnchor),
                    view.topAnchor.constraint(equalTo: vc.topLayoutGuide.bottomAnchor),
                    ])

                view.permissionsRequired = .all

                vc.beginAppearanceTransition(true, animated: false)
                vc.endAppearanceTransition()

                // anti debouncer
                RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))

                expect(view.frame.size.height).to(equal(CGFloat(0.0)))
            }
        }
    }

    class FakePermissionManager: NITPermissionsManager {
        var location = true
        var notifications = true

        override func isNotificationAvailable(_ completionHandler: @escaping (Bool) -> Void) {
            completionHandler(notifications)
        }
        
        override func isLocationGrantedAtLeast(minStatus: CLAuthorizationStatus) -> Bool {
            return location
        }
//        override func isNotificationAvailable() -> Bool {
//            return notifications
//        }
//
//        override func isLocationPartiallyGranted() -> Bool {
//            return location
//        }
    }

    class FakeCBPeripheralManager: CBPeripheralManager {
        var bluetooth = true

        override open var state: CBManagerState {
            get {
                return bluetooth ? .poweredOn : .poweredOff
            }
        }
    }

}
