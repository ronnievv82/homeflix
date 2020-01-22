use_frameworks!
inhibit_all_warnings!

source 'https://github.com/CocoaPods/Specs'

def pods
  pod 'GCDWebServer'
  pod 'PopcornTorrent', :path => './'
end

target 'homeflix' do
  platform :ios, '13.0'

  pods
end

target 'homeflixtvos' do
  platform :tvos, '13.0'
  pods
  pod 'TVVLCKit'
end
