//
//  HistoryViewController.swift
//  PuppyMonitor
//
//  Created by Michael Otmanski on 3/24/18.
//  Copyright © 2018 Michael Otmanski. All rights reserved.
//

import UIKit

final class HistoryViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupTableView()
    }

    private func setupNavBar() {
        var navBarTitle = "Bark History"
        if let user = DataManager().getUser(),
            let name = user.dogName {
            navBarTitle = "\(name) Bark History"
        }

        navigationItem.title = navBarTitle

        let closeButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(closeTapped))
        let clearButton = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearTapped))

        navigationItem.leftBarButtonItem = closeButton
        navigationItem.rightBarButtonItem = clearButton
    }

    @objc func closeTapped() {
        dismiss(animated: true, completion: nil)
    }

    @objc func clearTapped() {
        let alert = UIAlertController(title: "Are you sure?", message: "Do you want to delete your entire bark history? This action cannot be undone.", preferredStyle: .alert)

        let confirmAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            print("Delete")
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alert.addAction(confirmAction)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }

    private func setupTableView() {
        tableView.allowsSelection = false
    }
}

extension HistoryViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
