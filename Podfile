# Uncomment this line to define a global platform for your project
# platform :ios, '8.0'

target 'Pinsit' do

use_frameworks!

pod 'IQKeyboardManager'
pod 'INTULocationManager'
pod 'JGProgressHUD'
pod 'KLCPopup'
pod 'FCCurrentLocationGeocoder'
pod 'TSMessages', :git => 'https://github.com/KrauseFx/TSMessages.git' #Temp, Until Cocoapods integration
pod 'PPTopMostController'
pod 'DeviceGuru'
pod 'StaticDataTableViewController'
pod 'AsyncImageView'
pod 'DZNEmptyDataSet'
pod 'VIMVideoPlayer'
pod 'INSPullToRefresh'
pod 'Async', :git => 'https://github.com/duemunk/Async.git'

#Parse Dependencies
pod 'Parse', '>= 1.8.1'
pod 'ParseUI'
pod 'ParseCrashReporting'

end

target 'PinsitTests' do

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        installer.pods_project.build_configurations.each do |config|
            config.build_settings['ENABLE_BITCODE'] = 'NO'
        end

        target.build_configurations.each do |config|
            config.build_settings['ENABLE_BITCODe'] = 'NO'
        end
    end
end
