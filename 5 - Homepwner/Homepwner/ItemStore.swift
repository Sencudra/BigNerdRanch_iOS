//
//  ItenStore.swift
//  Homepwner
//
//  Created by Vladislav Tarasevich on 22.03.2020.
//  Copyright © 2020 Vladislav Tarasevich. All rights reserved.
//

import UIKit

final class ItemStore {

    // MARK: - Properties

    var allItems = [Item]()

    // MARK: - Init

    init() {
        for _ in 0..<5 {
            createItem()
        }
    }

    // MARK: - Methods

    @discardableResult func createItem() -> Item {
        let newItem = Item(random: true)
        allItems.append(newItem)
        return newItem
    }

}
