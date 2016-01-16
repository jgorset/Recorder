Pod::Spec.new do |s|
  s.name             = "Recorder"
  s.version          = "0.2.0"
  s.summary          = "Record and play audio"
  s.description      = <<-DESC
                       Record and play audio.
                       DESC
  s.homepage         = "https://github.com/jgorset/Recorder"
  s.license          = 'MIT'
  s.author           = { "Johannes Gorset" => "jgorset@gmail.com" }
  s.source           = { :git => "https://github.com/jgorset/Recorder.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/jgorset'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.ios.source_files = 'Sources/**/*'

  s.frameworks = 'AVFoundation'
end
