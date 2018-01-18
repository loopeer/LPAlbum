Pod::Spec.new do |s|

  s.name         = "LPAlbum"
  s.version      = "0.0.8"
  s.summary      = "Can a decent enough photo album, photo album multi-select"

  s.homepage     = "https://github.com/loopeer/LPAlbum"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.authors            = { "gaoyu" => "gaoyu@loopeer.com" }
  s.social_media_url   = "https://github.com/loopeer/LPAlbum"
  s.source       = { :git => "https://github.com/loopeer/LPAlbum.git", :tag => s.version }
  
  s.source_files  = ["LPAlbum/**/*.swift", "LPAlbum/LPAlbum.h"]
  s.public_header_files = ["LPAlbum/LPAlbum.h"]
  s.resource = 'LPAlbum/Others/LPAlbum.bundle'

  s.ios.deployment_target = "9.0"
  s.requires_arc = true
  
end
