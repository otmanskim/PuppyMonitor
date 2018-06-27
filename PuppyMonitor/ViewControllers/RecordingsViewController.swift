//
//  RecordingsViewController.swift
//  PuppyMonitor
//
//  Created by Michael Otmanski on 3/24/18.
//  Copyright © 2018 Michael Otmanski. All rights reserved.
//

import AVFoundation
import CoreData
import UIKit

final class RecordingsViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var recordButton: UIButton!
    @IBOutlet private weak var playbackButton: UIButton!
    @IBOutlet private weak var currentRecordingLabel: UILabel!
    
    var recordings: [String] = []

    private var audioPlayer: AVAudioPlayer?
    private var audioRecorder: AVAudioRecorder?
    private var audioSession: AVAudioSession?
    
    private var isRecording: Bool = false {
        didSet {
            if isRecording {
                recordButton.layer.cornerRadius = 4.0
                startRecording()
            } else {
                recordButton.layer.cornerRadius = 20.0
                audioRecorder?.stop()
            }
        }
    }
    
    private var currentRecordingName: String = "" {
        didSet {
            currentRecordingLabel.text = currentRecordingName
        }
    }
//    private var nowPlayingIndex: Int? To track which recording is playing to show speaker UI.

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        recordings = DataManager().getRecordings()
        tableView.reloadData()
        
        recordButton.layer.cornerRadius = 20.0
    }

    private func setupNavBar() {
        navigationItem.title = "My Recordings"

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addSound))
        navigationItem.rightBarButtonItem = addButton
    }

    private func updateRecordings() {
        recordings.removeAll()
        let docsURL = FileManager.documentsDirectory()

        do {
            let contents = try FileManager.default.contentsOfDirectory(at: docsURL, includingPropertiesForKeys: nil, options: [])
            for url in contents {
                recordings.append(url.lastPathComponent)
            }
        } catch {
            print("error")
        }
    }

    @objc func addSound() {
        performSegue(withIdentifier: "createNewSound", sender: nil)
    }
    
    @IBAction func recordButtonTapped() {
        self.isRecording = !self.isRecording
        self.currentRecordingName = "New_Recording.m4a"
    }
    
    @IBAction func playbackButtonTapped() {
        audioPlayer?.stop()
        audioSession? = AVAudioSession.sharedInstance()
        
        do {
//            try audioSession?.setCategory(AVAudioSessionCategoryPlayback)
            try audioSession?.setActive(true)
        } catch (let error) {
            print(error)
        }
        
        let filePath = FileManager.documentsDirectory().appendingPathComponent(currentRecordingName)
        
        do {
            //maybe some "speaker" icon on the cell to denote the one currently playing
            audioPlayer = try AVAudioPlayer(contentsOf: filePath)
            audioPlayer?.delegate = self
            audioPlayer?.play()
        } catch {
            print("error")
        }
    }
    
    private func startRecording() {
        audioSession = AVAudioSession.sharedInstance()
        
        audioSession?.requestRecordPermission({ [weak self] (allowed: Bool) in
            guard let strongSelf = self,
            allowed == true else { return }
            
            do {
                try strongSelf.audioSession?.setCategory(AVAudioSessionCategoryPlayAndRecord)
                try strongSelf.audioSession?.setActive(true)
            } catch (let error) {
                print(error)
            }
            
            let newFileName = FileManager.documentsDirectory().appendingPathComponent(strongSelf.currentRecordingName)
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            do {
                strongSelf.audioRecorder = try AVAudioRecorder(url: newFileName, settings: settings)
                strongSelf.audioRecorder?.delegate = self
                strongSelf.audioRecorder?.prepareToRecord()
                strongSelf.audioRecorder?.record()
            } catch {
                strongSelf.stopRecording(success: false)
            }
            
        })
    }
    
    fileprivate func stopRecording(success: Bool) {
        audioRecorder?.stop()
        audioRecorder = nil
        
        if success {
            //save recording name to core data, navigate back to list
            //            guard let newRecordingName = recordingNameTextField.text else { return }
            //            saveRecording(name: newRecordingName)
            //            dismiss(animated: true, completion: nil)
        } else {
//            showRecordingErrorAlert()
        }
    }
}

extension RecordingsViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        stopRecording(success: flag)
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
//        stopRecording(success: false)
    }
}

extension RecordingsViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordings.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recordingCell", for: indexPath)

        let recording = recordings[indexPath.row]
        cell.textLabel?.text = recording

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //stop any current playing audio
        audioPlayer?.stop()
        
        let selectedRecordingName = recordings[indexPath.row]
        let filePath = FileManager.documentsDirectory().appendingPathComponent(selectedRecordingName)

        do {
            //maybe some "speaker" icon on the cell to denote the one currently playing
            audioPlayer = try AVAudioPlayer(contentsOf: filePath)
            audioPlayer?.delegate = self
            audioPlayer?.play()
        } catch {
            print("error")
        }
    }
}

extension RecordingsViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        //hide audio icon on the cell?
        audioPlayer = nil
    }
}
