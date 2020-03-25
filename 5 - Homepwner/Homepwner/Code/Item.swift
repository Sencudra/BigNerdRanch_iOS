//
//  Item.swift
//  Homepwner
//
//  Created by Vladislav Tarasevich on 22.03.2020.
//  Copyright © 2020 Vladislav Tarasevich. All rights reserved.
//

import UIKit

final class Item: NSObject {

    // MARK: - Properties

    var name: String
    var valueInDollars: Int
    var serialNumber: String?
    var dateCreated: Date

    // MARK: - Init

    init(name: String, serialNumber: String?, valueInDollars: Int) {
        self.name = name
        self.valueInDollars = valueInDollars
        self.serialNumber = serialNumber
        self.dateCreated = Date()

        super.init()
    }

    convenience init(random: Bool = false) {
        if !random {
            self.init(name: "", serialNumber: nil, valueInDollars: 0)
        } else {
            let randomName = Item.makeRandomName()
            let randomValue = Int.random(in: 1..<100)
            let randomSerialNumber = UUID().uuidString.components(separatedBy: "-").first!

            self.init(name: randomName,
                serialNumber: randomSerialNumber,
                valueInDollars: randomValue)
        }
    }

    // MARK: - Private static methods

    private static func makeRandomName() -> String {
        let adjectives = ["Fluffy", "Rusty", "Shiny"]
        let nouns = ["Bear", "Spork", "Mac"]
        let randomAdjective = adjectives.randomElement()!
        let randomNoun = nouns.randomElement()!
        return "\(randomAdjective) \(randomNoun)"
    }

}
