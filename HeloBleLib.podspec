#
# Be sure to run `pod lib lint HeloBleLib.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'HeloBleLib'
  s.version          = '1.0.4'
  s.summary          = 'A BLE library'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'HeloBleLib is a BLE library'

  s.homepage         = 'https://github.com/zhuhon0821/'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'BruceZhu' => '276423059@qq.com' }
  s.source           = { :git => 'https://github.com/zhuhon0821/HeloBleLib.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  s.swift_version = '5.0'
  s.ios.deployment_target = '12.0'

  s.source_files = 'HeloBleLib/Classes/**/*'
  
  # s.resource_bundles = {
  #   'HeloBleLib' => ['HeloBleLib/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'CoreBluetooth', 'Foundation'
  
  s.dependency 'GRDB.swift', '~> 5.11.0'
  s.dependency 'SwiftProtobuf', '~> 1.26.0'
  s.dependency 'SwiftyBeaver'
#  s.dependency 'Protobuf'
  
  
end
