import AVFoundation
import QuartzCore

@objc public protocol RecorderDelegate: AVAudioRecorderDelegate {
  func audioMeterDidUpdate(dB: Float)
}

public class Recording : NSObject {

  static var directory: String {
    return NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
  }

  public weak var delegate: RecorderDelegate?
  public var metering: Bool = false

  private let session = AVAudioSession.sharedInstance()
  private var recorder: AVAudioRecorder!
  var player: AVAudioPlayer!
  var url: NSURL

  var bitRate = 192000
  var sampleRate = 44100.0
  var channels = 1

  var meteringEnabled: Bool {
    return metering && delegate != nil
  }

  private var link: CADisplayLink?

  public init(to: String, metering: Bool = false) throws {
    self.metering = metering
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
    recorder.meteringEnabled = meteringEnabled
  }

  public func record() throws {
    if recorder == nil {
      try prepare()
    }

    try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
    try session.overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker)

    recorder.record()

    if meteringEnabled {
      startMetering()
    }
  }

  public func stop() {
    if meteringEnabled {
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

    delegate?.audioMeterDidUpdate(dB)
  }

  private func startMetering() {
    link = CADisplayLink(target: self, selector: "updateMeter")
    link?.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
  }

  private func stopMetering() {
    link?.invalidate()
  }
}
