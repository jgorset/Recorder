import AVFoundation

@objc public protocol RecorderDelegate: AVAudioRecorderDelegate {
    optional func audioMeterDidUpdate(db: Float)
}

public class Recording : NSObject {
    var recorder: AVAudioRecorder!
    var player: AVAudioPlayer!
    var session: AVAudioSession!
    var delegate: RecorderDelegate!
    var metering: Bool
    var url: NSURL!
    var meterLink: CADisplayLink!
    
    var directory: NSString {
        return NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
    }
    
    var bitRate = 192000
    var sampleRate = 44100.0
    var channels = 1
    
    var prepared = false

    public init(to: NSString, on: RecorderDelegate, withMetering:Bool = false)
    {
        self.delegate = on
        self.metering = withMetering
        self.session  = AVAudioSession.sharedInstance()
        
        super.init()
        
        self.url = NSURL(fileURLWithPath: directory.stringByAppendingPathComponent(to))
    }
    
    public func prepare()
    {
        self.recorder = AVAudioRecorder(URL: url, settings: [
            AVFormatIDKey: kAudioFormatAppleLossless,
            AVEncoderAudioQualityKey: AVAudioQuality.Max.rawValue,
            AVEncoderBitRateKey: bitRate,
            AVNumberOfChannelsKey: channels,
            AVSampleRateKey: sampleRate
        ], error: nil)

        recorder.delegate = delegate
        
        recorder.prepareToRecord()
        
        if metering {
            recorder.meteringEnabled = metering
            startMetering()
        }
        
        prepared = true
    }

    public func record()
    {
        if !prepared {
            prepare()
        }

        self.session.setCategory(AVAudioSessionCategoryRecord, error: nil)
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
        self.session.setCategory(AVAudioSessionCategoryPlayback, error: nil)
        
        self.player = AVAudioPlayer(contentsOfURL: url, error: nil)
        player.play()
    }
    
    public func startMetering()
    {
        meterLink = CADisplayLink(target: self, selector: "updateMeter")
        meterLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
    }
    
    public func updateMeter()
    {
        recorder.updateMeters()

        var db = recorder.averagePowerForChannel(0)

        delegate.audioMeterDidUpdate?(db)
    }
    
    public func stopMetering()
    {
        meterLink.invalidate()
    }
    
}
