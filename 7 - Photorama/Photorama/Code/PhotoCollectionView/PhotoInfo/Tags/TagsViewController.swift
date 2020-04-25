//
//  TagsViewController.swift
//  Photorama
//
//  Created by Vladislav Tarasevich on 25.04.2020.
//  Copyright © 2020 Vladislav Tarasevich. All rights reserved.
//

import UIKit
import CoreData

final class TagsViewController: UITableViewController {

    // MARK: - Properties

    var store: PhotoStore!
    var photo: Photo!

    // MARK: - Private properties

    private let tagDataSource = TagDataSource()
    private var selectedIndexPaths = [IndexPath]()

    // MARK: - Overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = tagDataSource

        updateTags()
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tag = tagDataSource.tags[indexPath.row]

        if let index = selectedIndexPaths.firstIndex(of: indexPath) {
            selectedIndexPaths.remove(at: index)
            photo.removeFromTags(tag)
        } else {
            selectedIndexPaths.append(indexPath)
            photo.addToTags(tag)
        }

        do {
            try store.persistentContainer.viewContext.save()
        } catch {
            log(error: "Core Data save failed: \(error).")
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if selectedIndexPaths.firstIndex(of: indexPath) != nil {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
    }

    // MARK: - IBActions

    @IBAction private func done(_ sender: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    @IBAction private func addNewTag(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Add Tag", message: nil, preferredStyle: .alert)

        alertController.addTextField { field in
            field.placeholder = "tagItem"
            field.autocapitalizationType = .words
        }

        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            if let tagName = alertController.textFields?.first?.text {
                let context = self.store.persistentContainer.viewContext
                let newTag = NSEntityDescription.insertNewObject(forEntityName: "Tag", into: context)

                newTag.setValue(tagName, forKey: "name")

                do {
                    try self.store.persistentContainer.viewContext.save()
                } catch let error {
                    log(error: "Core Data save failed: \(error)")
                }
                self.updateTags()
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    // MARK: - Private methods

    private func updateTags() {
        store.fetchAllTags { result in
            switch result {
            case .success(let tags):
                self.tagDataSource.tags = tags

                guard let tags = self.photo.tags as? Set<Tag> else {
                    return
                }

                for tag in tags {
                    if let firstIndex = self.tagDataSource.tags.firstIndex(of: tag) {
                        let indexPath = IndexPath(row: firstIndex, section: 0)
                        self.selectedIndexPaths.append(indexPath)
                    }
                }

            case .failure(let error):
                log(error: "Got unexpected error \(error)")
            }
            self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        }
    }

}
