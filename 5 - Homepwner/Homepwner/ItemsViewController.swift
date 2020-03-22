//
//  ItemsViewController.swift
//  Homepwner
//
//  Created by Vladislav Tarasevich on 22.03.2020.
//  Copyright © 2020 Vladislav Tarasevich. All rights reserved.
//

import UIKit

final class ItemsViewController: UITableViewController {

    // MARK: - Properties

    var itemStore: ItemStore!

    // MARK: - Private properties

    private var valueThreshold: Int {
        return 50
    }

    private var itemsAboveThreshold: [Item] {
        return itemStore.allItems.filter{ $0.valueInDollars >= valueThreshold }
    }

    private var itemsBelowThreshold: [Item] {
        return itemStore.allItems.filter{ $0.valueInDollars < valueThreshold }
    }

    // MARK: - Overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        adjustTableViewContentInset()
    }

    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return itemsAboveThreshold.count
        } else {
            return itemsBelowThreshold.count + 1
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Above $\(valueThreshold)"
        } else {
            return "Under $\(valueThreshold)"
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 && indexPath.row >= itemsBelowThreshold.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewLastCell", for: indexPath)
            cell.textLabel?.text = "No more items!"
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
            let item = (indexPath.section == 0) ? itemsAboveThreshold[indexPath.row] : itemsBelowThreshold[indexPath.row]
            cell.textLabel?.text = item.name
            cell.detailTextLabel?.text = "$\(item.valueInDollars)"
            return cell
        }
    }

    // MARK: - Private methods

    private func adjustTableViewContentInset() {
        let statusBarHeight = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        let insets = UIEdgeInsets(top: statusBarHeight, left: 0, bottom: 0, right: 0)
        tableView.contentInset = insets
        tableView.scrollIndicatorInsets = insets
    }

}
