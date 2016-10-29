def all_pods
	use_frameworks!

	pod 'HockeySDK'
	pod 'DRPLoadingSpinner'
	pod 'CircleProgressView', '1.0.11'
	pod 'TTTAttributedLabel'
	pod 'RaptureXML@Frankly'
	pod 'ISO8601'
	pod 'GTMNSStringHTMLAdditions'
	pod 'JVFloatLabeledTextField'
	pod 'SORelativeDateTransformer'
	pod 'JGProgressHUD'
	pod '1PasswordExtension'
	pod 'SnapKit', '0.22.0'
	pod 'DFCache'
	pod 'Helpshift'
	pod 'Jiramazing', :path => "Dependencies/Jiramazing/Jiramazing.podspec"
	pod 'SDWebImage'

	pod 'Reveal-SDK', :configuration => ['Debug']
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

