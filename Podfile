# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'VideoDreamer' do
  
  # ignore all warnings from all pods
  inhibit_all_warnings!

  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for VideoDreamer
#  pod 'Firebase/Crashlytics', :inhibit_warnings => true
#  pod 'Firebase/Analytics', :inhibit_warnings => true
# Add the Firebase pod for Google Analytics
  pod 'FirebaseCrashlytics'
  pod 'IQKeyboardManager', :inhibit_warnings => true
  pod 'GTProgressBar', :inhibit_warnings => true
  pod 'AFNetworking', :git => 'https://github.com/xinhua01206/AFNetworking', :inhibit_warnings => true
  pod 'SSZipArchive'

  target 'VideoDreamerTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'VideoDreamerUITests' do
    # Pods for testing
  end

end

post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
        xcconfig_path = config.base_configuration_reference.real_path
        xcconfig = File.read(xcconfig_path)
        xcconfig_mod = xcconfig.gsub(/DT_TOOLCHAIN_DIR/, "TOOLCHAIN_DIR")
        File.open(xcconfig_path, "w") { |file| file << xcconfig_mod }
        config.build_settings['OTHER_LDFLAGS'] ||= ['$(inherited)']
        config.build_settings['OTHER_LDFLAGS'] << '-Xlinker -no_warn_duplicate_libraries'
      end
    end
  end
end
