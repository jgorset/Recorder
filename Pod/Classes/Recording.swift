import AVFoundation

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

    public init(to: NSString)
    {
        session  = AVAudioSession.sharedInstance()
        
        super.init()
        
        url = NSURL(fileURLWithPath: directory.stringByAppendingPathComponent(to))
    }
    
    public func prepare()
    {
        recorder = AVAudioRecorder(URL: url, settings: [
            AVFormatIDKey: kAudioFormatAppleLossless,
            AVEncoderAudioQualityKey: AVAudioQuality.Max.rawValue,
            AVEncoderBitRateKey: bitRate,
            AVNumberOfChannelsKey: channels,
            AVSampleRateKey: sampleRate
            ], error: nil)

        recorder.prepareToRecord()

        recorder.delegate = delegate
        recorder.meteringEnabled = metering
    }

    public func record()
    {
        if recorder == nil {
            prepare()
        }

        if metering {
            startMetering()
        }

        session.setCategory(AVAudioSessionCategoryRecord, error: nil)

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
