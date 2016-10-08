Pod::Spec.new do |s|
  s.name = 'Redes'
  s.version = '2.0.0'
  s.license = 'MIT'
  s.summary = 'High-level network layer abstraction library written in Swift'
  s.homepage = 'https://github.com/cuzv/Redes'
  s.author = { "Moch Xiao" => "cuzval@gmail.com" }
  s.source = { :git => 'https://github.com/cuzv/Redes.git', :tag => s.version }

  s.ios.deployment_target = '9.0'
  s.source_files = 'Sources/*.swift'
  s.requires_arc = true
  s.dependency "Alamofire", "~> 4.0"
end
