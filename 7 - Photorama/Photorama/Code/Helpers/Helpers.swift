//
//  Helpers.swift
//  Homepwner
//
//  Created by Vladislav Tarasevich on 31.03.2020.
//  Copyright © 2020 Vladislav Tarasevich. All rights reserved.
//

import Foundation

func log(error message: String, file: String = #file, line: Int = #line) {
    assertionFailure("[ERROR] \(file):\(line) - \(message)")
}

func log(warning message: String, file: String = #file, line: Int = #line) {
    print("[WARNING] \(file):\(line) - \(message)")
}

func log(info message: String, file: String = #file, line: Int = #line) {
    print("[INFO] \(file):\(line) - \(message)")
}
