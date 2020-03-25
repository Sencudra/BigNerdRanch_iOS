//
//  DetailViewController.swift
//  Homepwner
//
//  Created by Vladislav Tarasevich on 25.03.2020.
//  Copyright © 2020 Vladislav Tarasevich. All rights reserved.
//

import UIKit

final class DetailViewController: UIViewController {

    // MARK: - Properties

    var item: Item! {
        didSet {
            navigationItem.title = item.name
        }
    }

    var imageStore: ImageStore!

    // MARK: - Private properties

    @IBOutlet private weak var nameField: TextField!
    @IBOutlet private weak var serialField: TextField!
    @IBOutlet private weak var valueField: TextField!
    @IBOutlet private weak var dateCreatedButton: UIButton!
    @IBOutlet private weak var imageView: UIImageView!

    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        nameField.text = item.name
        serialField.text = item.serialNumber
        valueField.text = Formatter.numberFormatter.string(from: NSNumber(value: item.valueInDollars))
        dateCreatedButton.setTitle(Formatter.dateFormatter.string(from: item.dateCreated), for: .normal)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        dateCreatedButton.setTitle(Formatter.dateFormatter.string(from: item.dateCreated), for: .normal)
        imageView.image = imageStore.getImage(forKey: item.itemKey)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        view.endEditing(true)

        item.name = nameField.text ?? ""
        item.serialNumber = serialField.text

        if let valueText = valueField.text, let value = Formatter.numberFormatter.number(from: valueText) {
            item.valueInDollars = value.intValue
        } else {
            item.valueInDollars = 0
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        switch segue.identifier {
        case "datePicker":
            let destination = segue.destination as! DatePickerViewController
            destination.item = item
        default:
            log(error: "Uknown segue identifier: <\(segue.identifier ?? "nil")>")
        }
    }

    // MARK: - Private methods

    @IBAction private func backgroundTapped(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    @IBAction private func takePicture(_ sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
        } else {
            imagePicker.sourceType = .photoLibrary
        }

        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.cameraOverlayView = makeOverlay(for: imagePicker.view)
        present(imagePicker, animated: true, completion: nil)
    }

    @IBAction func deleteImage(_ sender: UIBarButtonItem) {
        imageStore.deleteImage(forKey: item.itemKey)
        imageView.image = nil
    }

    private func makeOverlay(for view: UIView) -> UIView {
        let imageWidth: CGFloat = 250
        let imageHeight: CGFloat = 250
        return makeCrosshairSubview(x: view.frame.midX - imageWidth / 2,
                                    y: view.frame.midY - imageHeight / 2 ,
                                    width: imageWidth,
                                    height: imageHeight)
    }

    private func makeCrosshairSubview(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) -> UIView {
        let image = UIImage(named: "crosshair")
        let rect = CGRect(x: 0, y: 0, width: width, height: height)

        UIGraphicsBeginImageContextWithOptions(rect.size, false, 1.0)
        image?.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        let imageView = UIImageView(image: newImage)
        let view = UIView()
        view.addSubview(imageView)
        view.frame = CGRect(x: x, y: y, width: width, height: height)
        return view
    }

}

extension DetailViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}

extension DetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
        imageStore.set(image, forKey: item.itemKey)
        imageView.image = image
        dismiss(animated: true, completion: nil)
    }

}
