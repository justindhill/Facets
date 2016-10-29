def all_pods
	use_frameworks!

	pod 'HockeySDK'
	pod 'DRPLoadingSpinner'
	pod 'CircleProgressView'
	pod 'TTTAttributedLabel'
	pod 'RaptureXML@Frankly'
	pod 'ISO8601', :git => "https://github.com/soffes/ISO8601", :branch => "swift3"
	pod 'GTMNSStringHTMLAdditions'
	pod 'RealmSwift'
	pod 'JVFloatLabeledTextField'
	pod 'SORelativeDateTransformer'
	pod 'JGProgressHUD'
	pod '1PasswordExtension'
	pod 'SnapKit'
	pod 'DFCache'
	pod 'Helpshift'

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

