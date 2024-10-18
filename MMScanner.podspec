
Pod::Spec.new do |s|
  s.name             = "MMScanner"
  s.version          = "1.2"
  s.summary          = "A two-dimensional code scanning and making tools used on iOS."
  s.homepage         = "https://github.com/ChaneyLau/MMScanner"
  s.license          = 'MIT'
  s.author           = { "ChaneyLau" => "1625977078@qq.com" }
  s.source           = { :git => "https://github.com/ChaneyLau/MMScanner.git", :tag => s.version.to_s }
  s.platform         = :ios, '8.0'
  s.requires_arc     = true
  s.source_files     = 'MMScanner/**/*.{h,m}'
  s.resources        = 'MMScanner/**/MMScanner.bundle'
  s.frameworks       = 'Foundation', 'UIKit', 'AVFoundation'

end
