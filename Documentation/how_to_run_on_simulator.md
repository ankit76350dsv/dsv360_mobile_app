we need to chagne only two files in order to run this one simulator that files are

## 1 - ios/Podfile
 - Add this in the file at line 35 like,
            target 'Runner' do
            use_frameworks!

            
            pod 'ZohoPortalAuth', '1.1.0'

            flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
            target 'RunnerTests' do
                inherit! :search_paths
            end
            end


 - paste the following code at around line 46, (end of file)
            post_install do |installer|
            installer.pods_project.targets.each do |target|
                flutter_additional_ios_build_settings(target)
                target.build_configurations.each do |config|
                # Allow arm64 simulator builds on Apple Silicon Macs.
                config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = ''
                end
            end
            end

## 2 - Podfile.lock
- add this under Pods:
                - ZohoPortalAuth (>= 1.0.5)
            - ZohoPortalAuth (1.1.0)

- add this under Dependencies
            - ZohoPortalAuth (= 1.1.0)


  