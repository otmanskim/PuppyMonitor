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
    var recordings: [String] = []

    private var audioPlayer: AVAudioPlayer?
    private var audioSession: AVAudioSession?
//    private var nowPlayingIndex: Int? To track which recording is playing to show speaker UI.

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateRecordings()
        tableView.reloadData()
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
