//
//  ViewController.swift
//  WorldTrotter
//
//  Created by Vladislav Tarasevich on 08.03.2020.
//  Copyright © 2020 Vladislav Tarasevich. All rights reserved.
//

import UIKit

class ConversionViewController: UIViewController, UITextFieldDelegate {

    // MARK: - Private properties

    @IBOutlet private weak var celsuisLabel: UILabel!
    @IBOutlet private weak var textField: UITextField!

    private var fahrenheitValue: Measurement<UnitTemperature>? {
        didSet {
            updateCelsiusValue()
        }
    }

    private var celsiusValue: Measurement<UnitTemperature>? {
        if let fahrenheitValue = fahrenheitValue {
            return fahrenheitValue.converted(to: .celsius)
        } else {
            return nil
        }
    }

    private let numberFormatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.minimumFractionDigits = 0
        nf.maximumFractionDigits = 1
        return nf
    }()

    // MARK: - Overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        print("ConversionViewController loaded is's view!")

        updateCelsiusValue()
    }

    // MARK: - Internal methods

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        var decimalSet = NSCharacterSet.decimalDigits
        decimalSet.insert(",")

        if !CharacterSet.init(charactersIn: string).isSubset(of: decimalSet) {
            return false
        }

        let existingTextHasSeparator = textField.text?.range(of: ",")
        let replacementTextHasSeparator = string.range(of: ",")

        if existingTextHasSeparator != nil, replacementTextHasSeparator != nil {
            return false
        } else if textField.text?.count == 0, replacementTextHasSeparator != nil {
            return false
        }
        return true
    }

    // MARK: - Private methods

    @IBAction private func fahrenheitFieldEditingChanged(_ sender: UITextField) {
        if let text = sender.text, let value = Double(text) {
            fahrenheitValue = Measurement(value: value, unit: .fahrenheit)
        } else {
            fahrenheitValue = nil
        }
    }

    @IBAction private func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        textField.resignFirstResponder()
    }

    private func updateCelsiusValue() {
        if let celsiusValue = celsiusValue {
            celsuisLabel.text = numberFormatter.string(from: NSNumber(value: celsiusValue.value))
        } else {
            celsuisLabel.text = Model.emptyCelsiusText
        }

    }

}

extension ConversionViewController {

    enum Model {

        static var emptyCelsiusText: String {
            return "0"
        }

    }

}
