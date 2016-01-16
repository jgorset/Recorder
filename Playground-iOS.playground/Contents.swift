// Recorder iOS Playground

import UIKit
import Recorder

class ViewController: UIViewController, RecorderDelegate {
  var recording: Recording!

  override func viewDidLoad() {
    super.viewDidLoad()

    recording = Recording(to: "recording.m4a")
    recording.delegate = self

    // Optionally, you can prepare the recording in the background to
    // make it start recording faster when you hit `record()`.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
      do {
        try self.recording.prepare()
      } catch {
        print(error)
      }
    }
  }

  func start() {
    do {
      try recording.record()
    } catch {
      print(error)
    }
  }

  func stop() {
    recording.stop()
  }

  func play() {
    do {
      try recording.play()
    } catch {
      print(error)
    }
  }
}