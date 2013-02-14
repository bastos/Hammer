Pod::Spec.new do |s|
  s.name         = "Hammer"
  s.version      = "0.1.2"
  s.summary      = "A simple Key/Value store library."
  s.homepage     = "https://github.com/bastos/Hammer"

  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Tiago Bastos" => "contact@tiagobastos.com" }
  s.source       = { :git => "https://github.com/bastos/Hammer.git", :tag => "0.1.2" }
  s.platform     = :ios, '4.3'

  s.source_files = 'Hammer/HMRStore.h', 'Hammer/HMRStore.m'

  s.public_header_files = 'Hammer/HMRStore.h'

  s.library   = 'libsqlite3'

  s.requires_arc = true
end
