import AVFoundation

public class Recording {
    var recorder: AVAudioRecorder!
    var player: AVAudioPlayer!
    var session: AVAudioSession!
    var delegate: AVAudioRecorderDelegate!
    
    var directory: NSString {
        return NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
    }
    
    var url: NSURL!
    
    var bitRate = 192000
    var sampleRate = 44100.0
    var channels = 1
    
    public init(to: NSString, on: AVAudioRecorderDelegate)
    {
        self.delegate = on
        self.session = AVAudioSession.sharedInstance()
        self.url = NSURL(fileURLWithPath: directory.stringByAppendingPathComponent(to))
    }
    
    public func record()
    {
        self.session.setCategory(AVAudioSessionCategoryRecord, error: nil)
        
        self.recorder = AVAudioRecorder(URL: url, settings: [
            AVFormatIDKey: kAudioFormatAppleLossless,
            AVEncoderAudioQualityKey: AVAudioQuality.Max.rawValue,
            AVEncoderBitRateKey: bitRate,
            AVNumberOfChannelsKey: channels,
            AVSampleRateKey: sampleRate
        ]
        , error: nil)

        recorder.delegate = delegate
        
        recorder.record()
    }
    
    public func stop()
    {
        recorder.stop()
    }
    
    public func play()
    {
        self.session.setCategory(AVAudioSessionCategoryPlayback, error: nil)
        
        self.player = AVAudioPlayer(contentsOfURL: url, error: nil)
        player.play()
    }
    
}
