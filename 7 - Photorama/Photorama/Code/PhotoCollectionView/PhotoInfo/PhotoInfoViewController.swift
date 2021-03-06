//
//  PhotoInfoViewController.swift
//  Photorama
//
//  Created by Vladislav Tarasevich on 18.04.2020.
//  Copyright © 2020 Vladislav Tarasevich. All rights reserved.
//

import UIKit

final class PhotoInfoViewController: UIViewController {

    // MARK: - Properties

    var photo: Photo! {
        didSet {
            navigationItem.title = photo.title
        }
    }

    var store: PhotoStore!

    // MARK: - Outlets

    @IBOutlet private var imageView: UIImageView!

    // MARK: - Overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        store.fetchImage(for: photo) { [weak self] result in
            guard let this = self else {
                log(error: "Unwrap nil value")
                return
            }

            switch result {
            case .success(let image):
                this.imageView.image = image

            case .failure(let error):
                log(error: "Unable to fetch image for photo with <\(error)>")
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showTags":
            guard let navController = segue.destination as? UINavigationController,
                let tagController = navController.topViewController as? TagsViewController else {
                    log(error: "Unable to cast.")
                    return
            }

            tagController.store = store
            tagController.photo = photo

        default:
            preconditionFailure("Unexpected segue identifier <\(segue.identifier ?? "nil")>")
        }
    }

}
