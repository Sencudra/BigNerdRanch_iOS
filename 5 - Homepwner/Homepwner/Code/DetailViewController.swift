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

    // MARK: - Private properties

    @IBOutlet private weak var nameField: TextField!
    @IBOutlet private weak var serialField: TextField!
    @IBOutlet private weak var valueField: TextField!
    @IBOutlet private weak var dateCreatedButton: UIButton!

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

}

extension DetailViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
