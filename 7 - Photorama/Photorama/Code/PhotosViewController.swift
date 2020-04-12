//
//  PhotosViewController.swift
//  Photorama
//
//  Created by Vladislav Tarasevich on 11.04.2020.
//  Copyright © 2020 Vladislav Tarasevich. All rights reserved.
//

import UIKit

final class PhotosViewController: UIViewController {

    // MARK: - Properties

    var photoStore: PhotoStore?

    // MARK: - Private properties

    // MARK: - Outlets

    @IBOutlet private var imageView: UIImageView?
    @IBOutlet private var segmentedControl: UISegmentedControl?

    // MARK: - Overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        requestPhotosFetch(for: .interestingPhotos)
    }

    // MARK: - IBActions

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        let method: Method
        switch sender.selectedSegmentIndex {
        case 0:
            method = .interestingPhotos
        case 1:
            method = .recentPhotos
        default:
            log(error: "Unknown segment \(sender.selectedSegmentIndex)")
            return
        }
        requestPhotosFetch(for: method)
    }

    // MARK: - Private methods

    private func requestPhotosFetch(for method: Method) {
        guard let store = photoStore else {
            log(error: "Got photoStore == nil")
            return
        }

        store.fetchPhotos(for: method) { [weak self] result in
            switch result {
            case .success(let photos):
                log(info: "Successfully got \(photos.count) photos")

                if let first = photos.first {
                    self?.updateImageView(with: first)
                }

            case .failure(let error):
                log(warning: "\(error)")
            }
        }
    }

    private func updateImageView(with photo: Photo) {
        guard let store = photoStore else {
            log(error: "Unable to use photoStore")
            return
        }

        store.fetchImage(for: photo) { [weak self] result in
            switch result {
            case .success(let image):
                self?.imageView?.image = image

            case .failure(let error):
                log(warning: "\(error)")
            }
        }
    }

}
