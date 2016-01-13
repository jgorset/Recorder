import AVFoundation
import QuartzCore

@objc public protocol RecorderDelegate: AVAudioRecorderDelegate {
  optional func audioMeterDidUpdate(dB: Float)
}

public class Recording : NSObject {

  static var directory: String {
    return NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
  }

  public weak var delegate: RecorderDelegate?
  public private(set) var url: NSURL

  let bitRate = 192000
  let sampleRate = 44100.0
  let channels = 1

  private let session = AVAudioSession.sharedInstance()
  private var recorder: AVAudioRecorder!
  private var player: AVAudioPlayer!
  private var link: CADisplayLink?

  var metering: Bool {
    return delegate?.respondsToSelector("audioMeterDidUpdate:") == true
  }

  public init(to: String) throws {
    url = NSURL(fileURLWithPath: Recording.directory).URLByAppendingPathComponent(to)

    super.init()
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

    delegate?.audioMeterDidUpdate?(dB)
  }

  private func startMetering() {
    link = CADisplayLink(target: self, selector: "updateMeter")
    link?.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
  }

  private func stopMetering() {
    link?.invalidate()
  }
}
