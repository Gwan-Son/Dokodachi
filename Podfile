# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Dokodachi' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  pod 'RxSwift', '6.7.1'
  pod 'RxCocoa', '6.7.1'
  pod 'Socket.IO-Client-Swift', '~> 16.1.0'

  # Pods for Dokodachi

  target 'DokodachiTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'DokodachiUITests' do
    # Pods for testing
  end

end
post_install do |installer|
    installer.generated_projects.each do |project|
        project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
            end
        end
    end
end
