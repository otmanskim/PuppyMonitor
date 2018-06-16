//
//  MainViewController.swift
//  PuppyMonitor
//
//  Created by Michael Otmanski on 3/24/18.
//  Copyright © 2018 Michael Otmanski. All rights reserved.
//

import UIKit

final class MainViewController: UIViewController {
    
    @IBOutlet private weak var toggleListeningButton: UIButton!
    @IBOutlet private weak var micSensitivitySlider: UISlider!
    @IBOutlet private weak var historyButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()

        if !UserDefaults.standard.bool(forKey: "hasAutoPresentedProfilePage") {
            //automatically present profile page on first app launch
            performSelector(onMainThread: #selector(viewProfileTapped), with: nil, waitUntilDone: true)
            UserDefaults.standard.set(true, forKey: "hasAutoPresentedProfilePage")
        }
    }

    private func configureNavBar() {
        navigationItem.title = "Puppy Monitor"

        let profileButton = UIBarButtonItem(title: "Profile", style: .plain, target: self, action: #selector(viewProfileTapped))
        navigationItem.rightBarButtonItem = profileButton
    }

    @objc func viewProfileTapped() {
        performSegue(withIdentifier: "userProfileSegue", sender: nil)
    }

    @IBAction func toggleListeningButtonTapped(_ sender: Any) {

    }

    @IBAction func micSensitivityValueChanged(_ sender: Any) {
        
    }
}
