#
# Be sure to run `pod lib lint YJHSocketRocket.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'YJHSocketRocket'
  s.version          = '0.1.1'
  s.summary          = 'A short description of YJHSocketRocket.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/Yinjianhua472392556/YJHSocketRocket'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '472392556@qq.com' => '18620526218@163.com' }
  s.source           = { :git => 'https://github.com/Yinjianhua472392556/YJHSocketRocket.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'

  s.source_files = 'YJHSocketRocket/Classes/**/*'
  
  # s.resource_bundles = {
  #   'YJHSocketRocket' => ['YJHSocketRocket/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'SocketRocket'
  s.dependency 'RxSwift'
  s.dependency 'RxCocoa'
  s.dependency 'SwifterSwift'

end
