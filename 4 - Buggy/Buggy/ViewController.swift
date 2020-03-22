//
//  ViewController.swift
//  Buggy
//
//  Created by Vladislav Tarasevich on 22.03.2020.
//  Copyright © 2020 Vladislav Tarasevich. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    // MARK: - Private methods

    @IBAction private func buttonTapped(_ sender: UIButton) {
        print("buttonTapped(_:)")
        print("Method: \(#function) in file: \(#file) line: \(#line)")

        badMethod()
    }

    private func badMethod() {
        let array = NSMutableArray()

        for i in 0..<10 {
            array.insert(i, at: i)
        }

        for _ in 0..<10 {
            array.removeObject(at: 0)
        }
    }

}

