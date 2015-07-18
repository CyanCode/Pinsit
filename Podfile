# Uncomment this line to define a global platform for your project
# platform :ios, '8.0'

target 'Pinsit' do

use_frameworks!

pod 'IQKeyboardManager'
pod 'INTULocationManager'
pod 'JGProgressHUD'
pod 'XLForm'
pod 'SVPullToRefresh'
pod 'SDWebImage'
pod 'KLCPopup'
pod 'FCCurrentLocationGeocoder'
pod 'TSMessages'
pod 'PPTopMostController'
pod 'DeviceGuru'

#Parse Dependencies
pod 'Parse'
pod 'ParseUI'

end

target 'PinsitTests' do

end

post_install do |installer|
    installer.project.targets.each do |target|
        installer.project.build_configurations.each do |config|
            config.build_settings['ENABLE_BITCODE'] = 'NO'
        end
        
        target.build_configurations.each do |config|
            config.build_settings['ENABLE_BITCODe'] = 'NO'
        end
    end
end
