source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '9.0'

target 'Preachers' do

use_frameworks!

pod 'Parse'
pod 'KVNProgress', '~> 2.2.1'
pod 'ReachabilitySwift', git: 'https://github.com/ashleymills/Reachability.swift'
pod 'WYPopoverController'

end

post_install do |installer|
installer.pods_project.targets.each do |target|
target.build_configurations.each do |config|
config.build_settings['SWIFT_VERSION'] = '3.0'
config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '10.10'
end
end
end