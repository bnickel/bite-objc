Pod::Spec.new do |s|
  s.name         = "Bite"
  s.version      = "0.1.0"
  s.summary      = "Functional operations for NSFastEnumeration."
  s.homepage     = "https://github.com/bnickel/bite-objc"
  s.license      = { :type => "MIT", :file => "LICENSE.md" }
  s.author       = { "Brian Nickel" => "brian.nickel@gmail.com" }
  s.platform     = :ios, "5.0"
  s.source       = { :git => "https://github.com/bnickel/bite-objc.git", :tag => "#{s.version}" }
  s.source_files = "Bite"
  s.requires_arc = true
end
