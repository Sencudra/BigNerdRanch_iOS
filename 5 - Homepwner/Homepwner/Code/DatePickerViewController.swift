//
//  DatePickerViewController.swift
//  Homepwner
//
//  Created by Vladislav Tarasevich on 25.03.2020.
//  Copyright © 2020 Vladislav Tarasevich. All rights reserved.
//

import UIKit

final class DatePickerViewController: UIViewController {

    // MARK: - Properties

    var item: Item!

    // MARK: - Private properties

    @IBOutlet private weak var datePicker: UIDatePicker!

    // MARK: - Methods

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        datePicker.date = item.dateCreated
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        item.dateCreated = datePicker.date
    }

}
