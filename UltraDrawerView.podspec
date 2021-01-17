Pod::Spec.new do |s|
  s.name             = 'UltraDrawerView'
  s.version          = '0.4.0'
  s.summary          = 'Simple swipe up view'
  s.homepage         = 'https://github.com/super-ultra/UltraDrawerView'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Ilya Lobanov' => 'esskeetit@imap.cc' }
  s.source           = { :git => 'https://github.com/super-ultra/UltraDrawerView.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.swift_version = '5.0'
  s.source_files = 'Sources/**/*'
  s.frameworks = 'UIKit'
end
