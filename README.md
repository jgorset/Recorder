# Recorder

[![CI Status](http://img.shields.io/travis/Johannes Gorset/Recorder.svg?style=flat)](https://travis-ci.org/Johannes Gorset/Recorder)
[![Version](https://img.shields.io/cocoapods/v/Recorder.svg?style=flat)](http://cocoapods.org/pods/Recorder)
[![License](https://img.shields.io/cocoapods/l/Recorder.svg?style=flat)](http://cocoapods.org/pods/Recorder)
[![Platform](https://img.shields.io/cocoapods/p/Recorder.svg?style=flat)](http://cocoapods.org/pods/Recorder)

## Usage

```swift
import UIKit
import AVFoundation
import Recorder

class ViewController: UIViewController, AVAudioRecorderDelegate {
    var recording: Recording!

    override func viewDidLoad()
    {
        super.viewDidLoad()

        recording = Recording(to: "recording.m4a", on: self)
    }

    func start()
    {
       recording.record()
    }

    func stop()
    {
        recording.stop()
    }

    func play()
    {
        recording.play()
    }

}
```

## Configuration

The following configurations may be made to the `Recording` instance:

* `bitRate` (default 192000)
* `sampleRate` (default 41000.0)
* `channels` (default 1)

## Requirements

* Balls of steel (it's my first pod, and it's really bad)

## Installation

Recorder is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
use_frameworks!
pod "Recorder"
```

## Author

Johannes Gorset, jgorset@gmail.com

## License

Recorder is available under the MIT license. See the LICENSE file for more info.
