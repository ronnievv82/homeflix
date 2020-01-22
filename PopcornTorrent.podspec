Pod::Spec.new do |s|
  s.name             = 'PopcornTorrent'
  s.version          = '1.3.15'
  s.summary          = "Torrent client for iOS and tvOS (Used by PopcornTime)"
  s.homepage         = "https://github.com/PopcornTimeTV/PopcornTorrent"
  s.license          = 'MIT'
  s.author           = { "PopcornTime" => "popcorn@time.tv" }
  s.requires_arc     = true
  s.source           = { :git => '' }
  s.platforms = { :ios => "13.0", :tvos => "13.0" }

  s.ios.vendored_frameworks = "PopcornTorrent/iOS/PopcornTorrent.framework"
  s.ios.source_files     = 'PopcornTorrent/iOS/PopcornTorrent.framework/Headers/*.h'
  s.ios.public_header_files = 'PopcornTorrent/iOS/PopcornTorrent.framework/Headers/*.h'
  s.ios.deployment_target = '13.0'

  s.tvos.vendored_frameworks = "PopcornTorrent/tvOS/PopcornTorrent.framework"
  s.tvos.source_files     = 'PopcornTorrent/tvOS/PopcornTorrent.framework/Headers/*.h'
  s.tvos.public_header_files = 'PopcornTorrent/tvOS/PopcornTorrent.framework/Headers/*.h'
  s.tvos.deployment_target = '13.0'

end
