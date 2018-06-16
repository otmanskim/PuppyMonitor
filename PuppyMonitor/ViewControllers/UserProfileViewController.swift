//
//  UserProfileViewController.swift
//  PuppyMonitor
//
//  Created by Michael Otmanski on 3/28/18.
//  Copyright © 2018 Michael Otmanski. All rights reserved.
//

import Foundation
import UIKit

final class UserProfileViewController: UIViewController {

    @IBOutlet fileprivate weak var imageView: UIImageView!
    @IBOutlet private weak var nameTextField: UITextField!

    private var imageViewTapRecognizer: UITapGestureRecognizer?
    private var viewTapRecognizer: UITapGestureRecognizer?
    private var user: UserProfile?

    let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        user = DataManager().getUser()

        configureNavBar()
        setupTapRecognizers()
        updateUI()

        imagePicker.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    private func updateUI() {
        nameTextField.delegate = self

        if let user = user {
            if let name = user.dogName {
                nameTextField.text = name
            } else {
                nameTextField.text = nil
                nameTextField.placeholder = "Enter your dog's name"
            }

            if let data = user.dogPhoto,
                let imageFromData = UIImage(data: data) {
                    imageView.image = imageFromData
            } else {
                imageView.image = #imageLiteral(resourceName: "dog-silhouette")
            }
        } else {
            //placeholder data
            nameTextField.text = nil
            nameTextField.placeholder = "Enter your dog's name"
            imageView.image = #imageLiteral(resourceName: "dog-silhouette")
        }
    }

    private func configureNavBar() {
        navigationItem.title = "Profile"

        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTapped))
        navigationItem.rightBarButtonItem = saveButton

        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        navigationItem.leftBarButtonItem = cancelButton
    }

    private func setupTapRecognizers() {
        imageView.isUserInteractionEnabled = true
        imageViewTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))

        guard let tap = imageViewTapRecognizer else { return }
        imageView.addGestureRecognizer(tap)

        view.isUserInteractionEnabled = true
        viewTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        guard let viewTap = viewTapRecognizer else { return }
        view.addGestureRecognizer(viewTap)
    }

    @objc func imageViewTapped() {
        let actionSheet = UIAlertController(title: "Edit Image?", message: "Do you want to change your dog's photo?", preferredStyle: .actionSheet)

        let yesAction = UIAlertAction(title: "Edit", style: .default) { _ in
            self.showImagePicker()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        actionSheet.addAction(yesAction)
        actionSheet.addAction(cancelAction)

        present(actionSheet, animated: true, completion: nil)
    }

    @objc func viewTapped() {
        nameTextField.resignFirstResponder()
    }

    func showImagePicker() {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary

        present(imagePicker, animated: true, completion: nil)
    }

    @objc func saveTapped() {
        let name = nameTextField.text
        var data: Data? = nil
        if let image = imageView.image {
            data = UIImageJPEGRepresentation(image, 0.75)
        }

        DataManager().updateUser(dogName: name, imageData: data)
        dismiss(animated: true, completion: nil)
    }

    @objc func cancelTapped() {
        dismiss(animated: true, completion: nil)
    }

    //MARK: Keyboard Notifications
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect, UIDevice.current.userInterfaceIdiom == .phone {
            UIView.animate(withDuration: 0.3) {
                self.view.frame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y - keyboardFrame.size.height, width: self.view.frame.width, height: self.view.frame.height)
            }
        }
    }

    @objc func keyboardWillHide() {
        UIView.animate(withDuration: 0.3) {
            self.view.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: self.view.frame.height)
        }
    }
}

extension UserProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.contentMode = .scaleAspectFit
            imageView.image = pickedImage
        }

        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension UserProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
