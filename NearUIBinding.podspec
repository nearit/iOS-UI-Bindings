Pod::Spec.new do |s|

s.name                  = 'NearUIBinding'
s.version               = '1.1.0'
s.summary               = 'nearit.com iOS UI Bindings'
s.description           = 'nearit.com iOS UI Bindings for Swift and Objective-C'

s.homepage              = 'https://github.com/nearit/iOS-UI-Bindings'
s.license               = 'MIT'

s.author                = {
'Francesco Leoni' => 'francesco@nearit.com'
}
s.source                = { :git => "https://github.com/nearit/iOS-UI-Bindings.git", :tag => s.version.to_s }
s.source_files          = 'Near-iOS-UI/Near-iOS-UI/**/*.{h,swift}'
s.resource_bundles      = { 'NearUIBinding' => ['Near-iOS-UI/Near-iOS-UI/**/*.xib', 'Near-iOS-UI/Near-iOS-UI/Resources/Images.xcassets'] }

s.ios.deployment_target = '9.0'
s.requires_arc          = true
s.dependency            'NearITSDK', '~> 2.7'

end
