source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!
target ‘big-red-shuttle’ do
  pod 'GoogleMaps'
  pod 'GooglePlaces'
  pod 'SwiftyJSON'
  pod 'Alamofire'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
