platform :ios, '9.0'
use_frameworks!

workspace 'Near-iOS-UI'

target 'NearUIBinding' do
    project 'Near-iOS-UI/Near-iOS-UI.xcodeproj'
    pod 'NearITSDKSwift', '~> 2.12.4'

    abstract_target 'Tests' do
        target "NeariOSUITests"

        pod 'Quick'
        pod 'Nimble'
        pod 'FBSnapshotTestCase'
        pod 'Nimble-Snapshots'
    end
end

target 'UI-Swift-Sample' do
    project 'UI-Swift-Sample/UI-Swift-Sample.xcodeproj'
    pod 'NearITSDKSwift', '~> 2.12.4'
    pod 'OHHTTPStubs/Swift'
end

