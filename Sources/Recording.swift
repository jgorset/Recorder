import AVFoundation
import QuartzCore

@objc public protocol RecorderDelegate: AVAudioRecorderDelegate {
  optional func audioMeterDidUpdate(dB: Float)
}

public class Recording : NSObject {

  @objc public enum State: Int {
    case None, Record, Play
  }

  static var directory: String {
    return NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
  }

  public weak var delegate: RecorderDelegate?
  public private(set) var url: NSURL
  public private(set) var state: State = .None

  let bitRate = 192000
  let sampleRate = 44100.0
  let channels = 1

  private let session = AVAudioSession.sharedInstance()
  private var recorder: AVAudioRecorder?
  private var player: AVAudioPlayer?
  private var link: CADisplayLink?

  var metering: Bool {
    return delegate?.respondsToSelector("audioMeterDidUpdate:") == true
  }

  // MARK: - Initializers

  public init(to: String) throws {
    url = NSURL(fileURLWithPath: Recording.directory).URLByAppendingPathComponent(to)
    super.init()
  }

  // MARK: - Record

  func prepare() throws {
    let settings: [String: AnyObject] = [
      AVFormatIDKey : NSNumber(int: Int32(kAudioFormatAppleLossless)),
      AVEncoderAudioQualityKey: AVAudioQuality.Max.rawValue,
      AVEncoderBitRateKey: bitRate,
      AVNumberOfChannelsKey: channels,
      AVSampleRateKey: sampleRate
    ]

    recorder = try AVAudioRecorder(URL: url, settings: settings)
    recorder?.prepareToRecord()
    recorder?.delegate = delegate
    recorder?.meteringEnabled = metering
  }

  public func record() throws {
    if recorder == nil {
      try prepare()
    }

    try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
    try session.overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker)

    recorder?.record()
    state = .Record

    if metering {
      startMetering()
    }
  }

  // MARK: - Playback

  public func play() throws {
    try session.setCategory(AVAudioSessionCategoryPlayback)

    player = try AVAudioPlayer(contentsOfURL: url)
    player?.play()
    state = .Play
  }

  public func stop() {
    if metering {
      stopMetering()
    }

    recorder?.stop()
    recorder = nil

    state = .None
  }

  // MARK: - Metering

  func updateMeter() {
    guard let recorder = recorder else { return }

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
