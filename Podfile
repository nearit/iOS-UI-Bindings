platform :ios, '9.0'
use_frameworks!

workspace 'Near-iOS-UI'

target 'NearUIBinding' do
    project 'Near-iOS-UI/Near-iOS-UI.xcodeproj'
    pod 'NearITSDK', '~> 2.9.5'

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
    pod 'NearITSDK', '~> 2.9.5'
    pod 'OHHTTPStubs/Swift'
end

