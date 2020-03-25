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

    var item: Item!

    // MARK: - Private properties

    @IBOutlet private weak var nameField: UITextField!
    @IBOutlet private weak var serialField: UITextField!
    @IBOutlet private weak var valueField: UITextField!
    @IBOutlet private weak var dateCreatedLabel: UILabel!

    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        nameField.text = item.name
        serialField.text = item.serialNumber
        valueField.text = Formatter.numberFormatter.string(from: NSNumber(value: item.valueInDollars))
        dateCreatedLabel.text = Formatter.dateFormatter.string(from: item.dateCreated)
    }

}


