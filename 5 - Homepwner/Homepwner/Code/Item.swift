//
//  Item.swift
//  Homepwner
//
//  Created by Vladislav Tarasevich on 22.03.2020.
//  Copyright © 2020 Vladislav Tarasevich. All rights reserved.
//

import UIKit

final class Item: NSObject, NSCoding, NSSecureCoding {

    // MARK: - Static properties

    static var supportsSecureCoding: Bool = true

    // MARK: - Private types

    enum Key {

        static var name: String {
            return "name"
        }

        static var valueInDollars: String {
            return "valueInDollars"
        }

        static var serialNumber: String {
            return "serialNumber"
        }

        static var dateCreated: String {
            return "dateCreated"
        }

        static var itemKey: String {
            return "itemKey"
        }

    }

    // MARK: - Properties

    var name: String
    var valueInDollars: Int
    var serialNumber: String?
    var dateCreated: Date
    var itemKey: String

    // MARK: - Init

    init?(coder decoder: NSCoder) {
        let newName = decoder.decodeObject(of: NSString.self, forKey: Key.name) as String?
        let newValueInDollars = decoder.decodeObject(of: NSNumber.self, forKey: Key.valueInDollars)?.intValue
        let newSerialNumber = decoder.decodeObject(of: NSString.self, forKey: Key.serialNumber) as String?
        let newDateCreated = decoder.decodeObject(of: NSNumber.self, forKey: Key.dateCreated)?.doubleValue as TimeInterval?
        let newItemKey = decoder.decodeObject(of: NSString.self, forKey: Key.itemKey) as String?

        if let newName = newName,
           let newValueInDollars = newValueInDollars,
           let newSerialNumber = newSerialNumber,
           let newDateCreated = newDateCreated,
           let newItemKey = newItemKey {

            name = newName
            valueInDollars = newValueInDollars
            serialNumber = newSerialNumber
            dateCreated = Date(timeIntervalSince1970: newDateCreated)
            itemKey = newItemKey
        } else {
            log(error: "Unable to decode items!")
            return nil
        }
        super.init()
    }

    init(name: String, serialNumber: String?, valueInDollars: Int) {
        self.name = name
        self.valueInDollars = valueInDollars
        self.serialNumber = serialNumber
        self.dateCreated = Date()
        self.itemKey = UUID().uuidString

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

    // MARK: - NSCoding extension

    func encode(with coder: NSCoder) {
        coder.encode(name as NSString, forKey: Key.name)
        coder.encode(itemKey as NSString, forKey: Key.itemKey)

        coder.encode(NSNumber(value: valueInDollars), forKey: Key.valueInDollars)
        coder.encode(NSNumber(value: Int(dateCreated.timeIntervalSince1970)), forKey: Key.dateCreated)

        if let number = serialNumber {
            coder.encode(number as NSString, forKey: Key.serialNumber)
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
