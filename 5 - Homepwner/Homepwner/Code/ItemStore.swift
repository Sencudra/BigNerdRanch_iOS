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
    var itemArchiveURL: URL = {
        let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return directoryURL.appendingPathComponent("items.archive")
    }()

    // MARK: - Private properties

    private var errorHandler = { message in
        preconditionFailure(message)
    }

    // MARK: - Init

    init() {
        guard let data = try? Data(contentsOf: itemArchiveURL) else {
            log(info: "Nothing found at \(itemArchiveURL)")
            return
        }
        guard let items = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [Item] else { errorHandler("Unable unwrap to [Item]") }
        allItems = items
    }

    // MARK: - Methods

    @discardableResult func createItem() -> Item {
        let newItem = Item(random: true)
        allItems.append(newItem)
        return newItem
    }

    func removeItem(_ item: Item) {
        if let index = allItems.firstIndex(of: item) {
            allItems.remove(at: index)
        }
    }

    func moveItem(from fromIndex: Int, to toIndex: Int) {
        if fromIndex == toIndex {
            return
        }

        let movedItem = allItems[fromIndex]
        allItems.remove(at: fromIndex)
        allItems.insert(movedItem, at: toIndex)
    }

    // MARK: - Archiving

    func saveChanges() {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: allItems, requiringSecureCoding: false)
            try data.write(to: itemArchiveURL)
        } catch {
            log(error: "Unable to save items to <\(itemArchiveURL))>")
        }
    }

}
