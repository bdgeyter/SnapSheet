#
# Be sure to run `pod lib lint SnapSheet.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SnapSheet'
  s.version          = '0.1.0'
  s.summary          = 'An Apple Maps-style bottom sheet that snaps 👌'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
An Apple Maps-style bottom sheet that snaps 👌
                       DESC

  s.homepage         = 'https://github.com/bdgeyter/SnapSheet'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Bram De Geyter' => 'bram.degeyter@palaplu.com' }
  s.source           = { :git => 'https://github.com/bdgeyter/SnapSheet.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'SnapSheet/Classes/**/*'
end
