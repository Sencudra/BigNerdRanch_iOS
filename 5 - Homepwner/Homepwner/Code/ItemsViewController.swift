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
    var imageStore: ImageStore!

    // MARK: - Overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = editButtonItem

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 65
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.reloadData()
    }

    // MARK: - Private methods

    @IBAction private func addNewItem(_ sender: UIBarButtonItem) {
        let newItem = itemStore.createItem()

        if let newItemIndex = itemStore.allItems.firstIndex(of: newItem) {
            let indexPath = IndexPath(row: newItemIndex, section: 0)
            tableView.insertRows(at: [indexPath], with: .automatic)
        } else {
            log(error: "Unable to find newItem in itemStore")
        }

    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        switch segue.identifier {
        case "showItemDetails":
            if let row = tableView.indexPathForSelectedRow?.row {
                let item = itemStore.allItems[row]
                let detailViewController = segue.destination as! DetailViewController
                detailViewController.item = item
                detailViewController.imageStore = imageStore
            }
        default:
            log(error: "Uknown segue identifier: <\(segue.identifier ?? "nil")>")
        }
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemStore.allItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as? ItemCell else {
            log(error: "Got not 'ItemCell' object!")
            return UITableViewCell()
        }

        let item = itemStore.allItems[indexPath.row]
        cell.nameLabelText = item.name
        cell.serialNumberLabelText = item.serialNumber
        cell.valueLabelText = "$\(item.valueInDollars)"
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let itemToDelete = itemStore.allItems[indexPath.row]

            let alertController = makeAlertForDeletingItem(withName: itemToDelete.name, deleteHandler: { [weak self] action in
                self?.itemStore.removeItem(itemToDelete)
                self?.tableView.deleteRows(at: [indexPath], with: .automatic)
                self?.imageStore.deleteImage(forKey: itemToDelete.itemKey)
            })
            present(alertController, animated: true, completion: nil)
        }
    }

    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        itemStore.moveItem(from: sourceIndexPath.row, to: destinationIndexPath.row)
    }

    // MARK: - Private methods

    private func makeAlertForDeletingItem(withName itemName: String, deleteHandler handler: @escaping ((UIAlertAction) -> Void)) -> UIAlertController {
        let ac = UIAlertController(title: "Delete \(itemName)?", message: "Are you sure you want to delete this item?", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        ac.addAction(cancelAction)

        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: handler)
        ac.addAction(deleteAction)
        return ac
    }

}
