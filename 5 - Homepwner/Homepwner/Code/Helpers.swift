//
//  Helpers.swift
//  Homepwner
//
//  Created by Vladislav Tarasevich on 23.03.2020.
//  Copyright © 2020 Vladislav Tarasevich. All rights reserved.
//

import Foundation

func log(error message: String, file: String = #file, line: Int = #line) {
    assertionFailure("\(file):\(line) - \(message)")
}

func log(info message: String, file: String = #file, line: Int = #line) {
    print("\(file):\(line) - \(message)")
}
