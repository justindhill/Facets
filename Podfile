def all_pods
	use_frameworks!

	pod 'HockeySDK'
	pod 'DRPSlidingTabView'
	pod 'DRPLoadingSpinner'
	pod 'TTTAttributedLabel'
	pod 'RaptureXML@Frankly'
	pod 'SDWebImage'
	pod 'ISO8601'
	pod 'GTMNSStringHTMLAdditions'
	pod 'Realm'
	pod 'JVFloatLabeledTextField'
	pod 'SORelativeDateTransformer'
	pod 'JGProgressHUD'
	pod '1PasswordExtension'
	pod 'SnapKit'
	pod 'DFCache'

	pod 'Reveal-iOS-SDK', :configuration => ['Debug']
end

target 'Facets' do
	all_pods
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
	  if config.name != "Release"
        config.build_settings['ENABLE_BITCODE'] = 'NO'
	  end
    end
  end
end

