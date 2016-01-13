import AVFoundation
import QuartzCore

@objc public protocol RecorderDelegate: AVAudioRecorderDelegate {
  optional func audioMeterDidUpdate(dB: Float)
}

public class Recording : NSObject {
  public var delegate: RecorderDelegate!

  var session: AVAudioSession!
  var recorder: AVAudioRecorder!
  var player: AVAudioPlayer!
  var url: NSURL!

  var bitRate = 192000
  var sampleRate = 44100.0
  var channels = 1

  var metering: Bool {
    return delegate.respondsToSelector("audioMeterDidUpdate:")
  }



  var directory: NSString {
    return NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
  }

  private var link: CADisplayLink?

  public init(to: String) {
    session  = AVAudioSession.sharedInstance()

    super.init()

    url = NSURL(fileURLWithPath: directory.stringByAppendingPathComponent(to))
  }

  public func prepare() throws {
    let settings: [String: AnyObject] = [
      AVFormatIDKey : NSNumber(int: Int32(kAudioFormatAppleLossless)),
      AVEncoderAudioQualityKey: AVAudioQuality.Max.rawValue,
      AVEncoderBitRateKey: bitRate,
      AVNumberOfChannelsKey: channels,
      AVSampleRateKey: sampleRate
    ]

    recorder = try AVAudioRecorder(URL: url, settings: settings)

    recorder.prepareToRecord()
    recorder.delegate = delegate
    recorder.meteringEnabled = metering
  }

  public func record() throws {
    if recorder == nil {
      try prepare()
    }

    try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
    try session.overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker)

    recorder.record()

    if metering {
      startMetering()
    }
  }

  public func stop() {
    if metering {
      stopMetering()
    }

    recorder.stop()
  }

  public func play() throws {
    try session.setCategory(AVAudioSessionCategoryPlayback)

    player = try AVAudioPlayer(contentsOfURL: url)
    player.play()
  }

  public func updateMeter() {
    recorder.updateMeters()

    let dB = recorder.averagePowerForChannel(0)

    delegate.audioMeterDidUpdate?(dB)
  }

  private func startMetering() {
    link = CADisplayLink(target: self, selector: "updateMeter")
    link?.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
  }

  private func stopMetering() {
    link?.invalidate()
  }
}
