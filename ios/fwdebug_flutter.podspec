#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint fwdebug_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'fwdebug_flutter'
  s.version          = '1.0.2'
  s.summary          = 'iOS FWDebug Wrapper for Flutter.'
  s.description      = <<-DESC
iOS FWDebug Wrapper for Flutter.
                       DESC
  s.homepage         = 'https://github.com/lszzy/fwdebug_flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Wu Yong' => 'admin@wuyong.site' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'FWDebug', :configurations => 'Debug'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => '$(inherited)'
  }
  s.swift_version = '5.0'
end
