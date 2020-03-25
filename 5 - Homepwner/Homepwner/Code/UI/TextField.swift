//
//  TextField.swift
//  Homepwner
//
//  Created by Vladislav Tarasevich on 25.03.2020.
//  Copyright © 2020 Vladislav Tarasevich. All rights reserved.
//

import UIKit

final class TextField: UITextField {

    // MARK: - Methods

    override func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()
        borderStyle = .line
        return true
    }

    override func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        borderStyle = .roundedRect
        return true
    }

}
