//
//  AudioManager.swift
//  PuppyMonitor
//
//  Created by Michael Otmanski on 6/5/18.
//  Copyright © 2018 Michael Otmanski. All rights reserved.
//

import Foundation
import AVFoundation

final class AudioManager: NSObject {

    private var timer: Timer?
    private var lowPassResults: Double?

    private lazy var audioSession: AVAudioSession? = {
        return AVAudioSession.sharedInstance()
    }()

    private var audioPlayer: AVAudioPlayer?
    private var audioRecording: AVAudioRecorder?

    func startRecording(saveToUrl: URL) {
        
    }

    func stopRecording() { }

    func startRecordingForMetering() { }

    func playSoundAt(path: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: path)
            audioPlayer?.delegate = self
            audioPlayer?.play()
        } catch (let error) {
            print("Playing sound at: \(path) encountered error: \(error)")
        }
    }

    func playRandomSound() { }

    func isRecording() -> Bool { return false }
}

extension AudioManager: AVAudioPlayerDelegate, AVAudioRecorderDelegate {

    //MARK: AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {

    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {

    }

    //MARK: AVAudioRecorderDelegate
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {

    }

    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {

    }
}

enum PlayingReason {
    case bark
    case soundTapped
}
