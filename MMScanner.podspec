
Pod::Spec.new do |s|
  s.name             = "MMScanner"
  s.version          = "1.1"
  s.summary          = "A two-dimensional code scanning and making tools used on iOS."
  s.homepage         = "https://github.com/CheeryLau/MMScanner"
  s.license          = 'MIT'
  s.author           = { "Cheery Lau" => "1625977078@qq.com" }
  s.source           = { :git => "https://github.com/CheeryLau/MMScanner.git", :tag => s.version.to_s }
  s.platform         = :ios, '7.0'
  s.requires_arc     = true
  s.source_files     = 'MMScanner/**/*.{h,m}'
  s.resources        = 'MMScanner/**/MMScanner.bundle'
  s.frameworks       = 'Foundation', 'UIKit', 'AVFoundation'

end
