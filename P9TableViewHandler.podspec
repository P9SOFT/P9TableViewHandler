Pod::Spec.new do |s|

  s.name         = "P9TableViewHandler"
  s.version      = "1.1.0"
  s.summary      = "TableView handling library. Reduce typing and manage simple."
  s.homepage     = "https://github.com/P9SOFT/P9TableViewHandler"
  s.license      = { :type => 'MIT' }
  s.author       = { "Tae Hyun Na" => "taehyun.na@gmail.com" }

  s.ios.deployment_target = '8.0'

  s.source       = { :git => "https://github.com/P9SOFT/P9TableViewHandler.git", :tag => "1.1.0" }
  s.swift_version = "4.2"
  s.source_files  = "Sources/*.swift"

end
