# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

target 'Robosuke2' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  pod 'Alamofire', '~> 4.0'
  pod 'ObjectMapper', '~> 2.0'
  pod 'PageMenu', :git => 'https://github.com/orazz/PageMenu.git'

  # Pods for Robosuke2

  target 'Robosuke2Tests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'Robosuke2UITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
          config.build_settings['SWIFT_VERSION'] = '3.0'
      end
   end
end
