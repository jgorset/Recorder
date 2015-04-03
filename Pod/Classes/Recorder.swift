import AVFoundation

class Recording {
    var recorder: AVAudioRecorder!
    var player: AVAudioPlayer!
    var session: AVAudioSession!
    var delegate: AVAudioRecorderDelegate!
    
    var directory: NSString {
        return NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
    }
    
    var url: NSURL!
    
    let settings = [
        AVFormatIDKey: kAudioFormatAppleLossless,
        AVEncoderAudioQualityKey: AVAudioQuality.Max.rawValue,
        AVEncoderBitRateKey: 32000,
        AVNumberOfChannelsKey: 2,
        AVSampleRateKey: 44100.0
    ]
    
    init(to: NSString, on: AVAudioRecorderDelegate)
    {
        self.delegate = on
        self.session = AVAudioSession.sharedInstance()
        self.url = NSURL(fileURLWithPath: directory.stringByAppendingPathComponent(to))
    }
    
    func record()
    {
        self.session.setCategory(AVAudioSessionCategoryRecord, error: nil)
        
        self.recorder = AVAudioRecorder(URL: url, settings: settings, error: nil)
        recorder.delegate = delegate
        
        recorder.record()
    }
    
    func stop()
    {
        recorder.stop()
    }
    
    func play()
    {
        self.session.setCategory(AVAudioSessionCategoryPlayback, error: nil)
        
        self.player = AVAudioPlayer(contentsOfURL: url, error: nil)
        player.play()
    }
    
}
