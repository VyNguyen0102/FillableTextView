#
# Be sure to run `pod lib lint FillableTextView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FillableTextView'
  s.version          = '1.0'
  s.summary          = 'Using for create fill in the blanks - especially leaning language grammar appication'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

s.description      = <<-DESC
                        Using for create fill in the blanks
                        especially leaning language grammar appication

                        Feature:
                        1. Custom textbox color, text color, font size.
                        2. Select copy and paste.

                        Comming soon:
                        1. Custom text place holder (make it bigger).
                        2. Allow drag and drop.
                        DESC

  s.homepage         = 'https://github.com/VyNguyen0102/FillableTextView'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Vy Nguyen' => 'nguyenvanvy0102@gmail.com' }
  s.source           = { :git => 'https://github.com/VyNguyen0102/FillableTextView.git',
                            :branch => 'master',
                            :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'
  s.swift_version = '4.2'
  s.source_files = 'Sources/Classes/**/*'
  
  # s.resource_bundles = {
  #   'FillableTextView' => ['FillableTextView/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
