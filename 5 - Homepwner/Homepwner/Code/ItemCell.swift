//
//  ItemCell.swift
//  Homepwner
//
//  Created by Vladislav Tarasevich on 23.03.2020.
//  Copyright © 2020 Vladislav Tarasevich. All rights reserved.
//

import UIKit

class ItemCell: UITableViewCell {

    // MARK: - Properties

    var nameLabelText: String? {
        get {
            return nameLabel.text
        }
        set {
            nameLabel?.text = newValue
        }
    }

    var serialNumberLabelText: String? {
        get {
            return serialNumberLabel.text
        }
        set {
            serialNumberLabel?.text = newValue
        }
    }

    var valueLabelText: String? {
        get {
            return valueLabel.text
        }
        set {
            valueLabel?.text = newValue
        }
    }

    // MARK: - Private properties

    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var serialNumberLabel: UILabel!
    @IBOutlet private weak var valueLabel: UILabel!



}
