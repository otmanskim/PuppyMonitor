//
//  CreateRecordingViewController.swift
//  PuppyMonitor
//
//  Created by Michael Otmanski on 3/24/18.
//  Copyright © 2018 Michael Otmanski. All rights reserved.
//

import AVFoundation
import CoreData
import UIKit

final class CreateRecordingViewController: UIViewController {

    @IBOutlet private weak var recordingNameTextField: UITextField!
    @IBOutlet private weak var toggleRecordingButton: UIButton!

    private var isRecording: Bool = false {
        didSet {
            if isRecording {
                toggleRecordingButton.setTitle("Stop Recording", for: .normal)
            } else {
                toggleRecordingButton.setTitle("Start Recording", for: .normal)
            }
        }
    }

    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var audioSession: AVAudioSession?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupRecordingSession()
    }

    private func setupNavBar() {
        navigationItem.title = "New Recording"
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))

        navigationItem.rightBarButtonItem = saveButton
    }

    private func setupRecordingSession() {
        do {
            try audioSession?.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioSession?.setActive(true)
            audioSession?.requestRecordPermission({ allowed in
                if !allowed {
                    print("AudioSession Permissions Error!")
                }
            })
        } catch {
            print("caught error setting up audio session")
        }
    }

    @objc func save() {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func toggleRecordingButtonTapped(_ sender: Any) {
        isRecording = !isRecording

        if isRecording {
            startRecording()
        } else {
            stopRecording(success: true)
        }
    }

    private func startRecording() {
        //TODO: Also make sure a file doesn't already exist with this name
        guard let recordingName = recordingNameTextField.text else {
            showMissingNameAlert()
            return
        }

        audioSession = AVAudioSession.sharedInstance()

        let newFileName = FileManager.documentsDirectory().appendingPathComponent(recordingName)

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: newFileName, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
        } catch {
            stopRecording(success: false)
        }
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
            showRecordingErrorAlert()
        }
    }

    private func saveRecording(name: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

        let managedContext = appDelegate.persistentContainer.viewContext

        guard let entity = NSEntityDescription.entity(forEntityName: "Recording", in: managedContext) else { return }

        let recording = NSManagedObject(entity: entity, insertInto: managedContext)

        recording.setValue(name, forKey: "name")

        do {
            try managedContext.save()
        } catch {
            print("Failed to save recording")
        }
    }

    private func showMissingNameAlert() {
        let alert = UIAlertController(title: "Missing Recording Name", message: "Before beginning to record, please provide a name for the recording so it can be saved.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)

        present(alert, animated: true, completion: nil)
    }

    private func showRecordingErrorAlert() {
        let alert = UIAlertController(title: "Recording Error", message: "Something went wrong attempting to create your recording. Please try again.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)

        present(alert, animated: true, completion: nil)
    }
}

extension CreateRecordingViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        stopRecording(success: flag)
    }

    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        stopRecording(success: false)
    }
}
