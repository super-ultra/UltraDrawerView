Pod::Spec.new do |s|
  s.name             = 'UltraDrawerView'
  s.version          = '0.1.0'
  s.summary          = 'Simple swipe up view'
  s.homepage         = 'https://github.com/super-ultra/UltraDrawerView'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Ilya Lobanov' => 'owlefy@gmail.com' }
  s.source           = { :git => 'https://github.com/super-ultra/UltraDrawerView.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.swift_version = '4.2'
  s.source_files = 'Sources/**/*'
  s.frameworks = 'UIKit'
  s.dependency 'pop', '~> 1.0'
end
