Pod::Spec.new do |s|
  s.name         = "WobbleView"
  s.version      = "1.1"
  s.summary      = "WobbleView is an implementation of a recently popular wobble effect for any view in your app."
  s.homepage     = "https://github.com/inFullMobile/WobbleView"
  s.license      = { :type => "MIT" }
  s.author       = { "Wojciech Lukaszuk" => "wojciech.lukaszuk@infullmobile.com" }
  s.source       = { :git => "https://github.com/inFullMobile/WobbleView.git", :tag => s.version }
  s.source_files  = "Classes", "Classes/**/*.{swift}"
  s.ios.deployment_target = "8.0"
end
