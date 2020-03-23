//
//  ItemsViewController.swift
//  Homepwner
//
//  Created by Vladislav Tarasevich on 22.03.2020.
//  Copyright © 2020 Vladislav Tarasevich. All rights reserved.
//

import UIKit

final class ItemsViewController: UITableViewController {

    // MARK: - Private types

    enum Section: Int {
        case above = 0
        case below
    }

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

    // MARK: - Private methods

    @IBAction private func addNewItem(_ sender: UIButton) {
        let newItem = itemStore.createItem()
        let indexPath: IndexPath

        if let newItemIndex = itemsBelowThreshold.firstIndex(of: newItem) {
            indexPath = IndexPath(row: newItemIndex, section: Section.below.rawValue)
        } else if let newItemIndex = itemsAboveThreshold.firstIndex(of: newItem) {
            indexPath = IndexPath(row: newItemIndex, section: Section.above.rawValue)
        } else {
            log(error: "Unable to find newItem in itemStore")
            return
        }
        tableView.insertRows(at: [indexPath], with: .automatic)
    }

    @IBAction private func toggleEditingMode(_ sender: UIButton) {
        if isEditing {
            sender.setTitle("Edit", for: .normal)
            setEditing(false, animated: true)
        } else {
            sender.setTitle("Done", for: .normal)
            setEditing(true, animated: true)
        }
    }

    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let newSection = Section(rawValue: section)

        switch newSection {
        case .above:
            return itemsAboveThreshold.count
        case .below:
            return itemsBelowThreshold.count + 1
        default:
            log(error: "Invalid section \(section)")
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let newSection = Section(rawValue: section)

        switch newSection {
        case .above:
            return "Above $\(valueThreshold)"
        case .below:
            return "Under $\(valueThreshold)"
        default:
            log(error: "Invalid section \(section)")
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let newSection = Section(rawValue: indexPath.section)

        if newSection == .below && indexPath.row >= itemsBelowThreshold.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewLastCell", for: indexPath)
            cell.textLabel?.text = "No more items!"
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
            let item = (newSection == .above) ? itemsAboveThreshold[indexPath.row] : itemsBelowThreshold[indexPath.row]
            cell.textLabel?.text = item.name
            cell.detailTextLabel?.text = "$\(item.valueInDollars)"
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let itemToDelete = itemStore.allItems[indexPath.row]

            let alertController = makeAlertForDeletingItem(withName: itemToDelete.name, deleteHandler: { [weak self] action in
                self?.itemStore.removeItem(itemToDelete)
                self?.tableView.deleteRows(at: [indexPath], with: .automatic)
            })
            present(alertController, animated: true, completion: nil)
        }
    }

    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        itemStore.moveItem(from: itemsAboveThreshold.count * sourceIndexPath.section + sourceIndexPath.row,
                           to: itemsAboveThreshold.count * sourceIndexPath.section + destinationIndexPath.row)
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if Section(rawValue: indexPath.section) == .below && indexPath.row == itemsBelowThreshold.count {
            return false
        }
        return true
    }

    override func tableView(_ tableView: UITableView,
                            targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath,
                            toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        guard let sourceSection = Section(rawValue: sourceIndexPath.section), let proposedDestinationSection = Section(rawValue: proposedDestinationIndexPath.section) else {
            log(error: "Invalid section move from \(sourceIndexPath.section) to \(proposedDestinationIndexPath.section)")
            return sourceIndexPath
        }
        var destinationPath = IndexPath(row: proposedDestinationIndexPath.row, section: sourceIndexPath.section)

        if sourceSection != proposedDestinationSection {
            destinationPath.row = (proposedDestinationSection == .above) ? 0 : itemsAboveThreshold.count - 1
        }

        if proposedDestinationSection == .below {
            destinationPath.row = (proposedDestinationIndexPath.row >= itemsBelowThreshold.count) ? proposedDestinationIndexPath.row - 1 : proposedDestinationIndexPath.row
        }

        return destinationPath
    }

    // MARK: - Private methods

    private func adjustTableViewContentInset() {
        let statusBarHeight = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        let insets = UIEdgeInsets(top: statusBarHeight, left: 0, bottom: 0, right: 0)
        tableView.contentInset = insets
        tableView.scrollIndicatorInsets = insets
    }

    private func makeAlertForDeletingItem(withName itemName: String, deleteHandler handler: @escaping ((UIAlertAction) -> Void)) -> UIAlertController {
        let ac = UIAlertController(title: "Delete \(itemName)?", message: "Are you sure you want to delete this item?", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        ac.addAction(cancelAction)

        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: handler)
        ac.addAction(deleteAction)
        return ac
    }

}
