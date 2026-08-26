#
# Perkox Flutter SDK CocoaPods Spec
#
Pod::Spec.new do |s|
  s.name             = 'perkox_flutter_sdk'
  s.version          = '2.0.1'
  s.summary          = 'Perkox Offerwall Flutter SDK for iOS'
  s.description      = <<-DESC
Perkox Offerwall Flutter SDK bridging native iOS Offerwall.
                       DESC
  s.homepage         = 'https://github.com/perkoxofficial/perkox-flutter-sdk'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Perkox' => 'support@perkox.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'perkox_flutter_sdk/Sources/perkox_flutter_sdk/**/*.{h,m,mm,swift}'
  s.exclude_files    = 'Frameworks/**/*'
  s.dependency 'Flutter'
  s.platform         = :ios, '13.0'

  # Link prebuilt native PerkoxOfferwall XCFramework
  s.vendored_frameworks = 'Frameworks/PerkoxOfferwall.xcframework'
  s.preserve_paths      = 'Frameworks/*'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version       = '5.0'
end
