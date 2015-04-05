import AVFoundation

@objc public protocol RecorderDelegate: AVAudioRecorderDelegate {
    optional func audioMeterDidUpdate(dB: Float)
}

public class Recording : NSObject {
    public var delegate: RecorderDelegate!

    var session: AVAudioSession!
    var player: AVAudioPlayer!
    var metering: Bool
    var url: NSURL!

    var bitRate = 192000
    var sampleRate = 44100.0
    var channels = 1

    var directory: NSString {
        return NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
    }

    lazy var recorder: AVAudioRecorder = {
        var recorder = AVAudioRecorder(URL: self.url, settings: [
            AVFormatIDKey: kAudioFormatAppleLossless,
            AVEncoderAudioQualityKey: AVAudioQuality.Max.rawValue,
            AVEncoderBitRateKey: self.bitRate,
            AVNumberOfChannelsKey: self.channels,
            AVSampleRateKey: self.sampleRate
        ], error: nil)

        recorder.delegate = self.delegate
        recorder.meteringEnabled = self.metering

        return recorder
    }()

    private var link: CADisplayLink?

    public init(to: NSString, withMetering:Bool = false)
    {
        metering = withMetering
        session  = AVAudioSession.sharedInstance()
        
        super.init()
        
        url = NSURL(fileURLWithPath: directory.stringByAppendingPathComponent(to))
    }
    
    public func prepare()
    {
        // This feels a weird thing to do, but since Swift won't let you reference properties
        // without assigning them and I really need to just hit this lazy property to compute it
        // I'ma go ahead and just assign it to an arbitrary variable.
        var prepared = recorder
    }

    public func record()
    {
        session.setCategory(AVAudioSessionCategoryRecord, error: nil)

        recorder.prepareToRecord()

        startMetering()
        recorder.record()
    }
    
    public func stop()
    {
        recorder.stop()

        if metering {
            stopMetering()
        }
    }
    
    public func play()
    {
        session.setCategory(AVAudioSessionCategoryPlayback, error: nil)

        player = AVAudioPlayer(contentsOfURL: url, error: nil)
        player.play()
    }

    public func updateMeter()
    {
        recorder.updateMeters()

        var dB = recorder.averagePowerForChannel(0)

        delegate.audioMeterDidUpdate?(dB)
    }

    private func startMetering()
    {
        link = CADisplayLink(target: self, selector: "updateMeter")
        link?.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
    }
    
    private func stopMetering()
    {
        link?.invalidate()
    }
    
}
