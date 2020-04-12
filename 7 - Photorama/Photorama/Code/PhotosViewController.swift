//
//  PhotosViewController.swift
//  Photorama
//
//  Created by Vladislav Tarasevich on 11.04.2020.
//  Copyright © 2020 Vladislav Tarasevich. All rights reserved.
//

import UIKit

final class PhotosViewController: UIViewController, UICollectionViewDelegate {

    // MARK: - Properties

    var photoStore: PhotoStore?
    var photoDataSource = PhotoDateSource()

    // MARK: - Outlets

    @IBOutlet private var segmentedControl: UISegmentedControl?
    @IBOutlet private var collectionView: UICollectionView?

    // MARK: - Overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.dataSource = photoDataSource
        collectionView?.delegate = self
        requestPhotosFetch(for: .interestingPhotos)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let photo = photoDataSource.photos[indexPath.row]

        guard let store = photoStore else {
            log(error: "photoStore is nil")
            return
        }

        store.fetchImage(for: photo) { [weak self] result in
            guard let this = self else {
                log(error: "'self' is nil")
                return
            }
            guard let photoIndex = this.photoDataSource.photos.firstIndex(of: photo), case .success(let image) = result else {
                log(warning: "Unable to load photo")
                return
            }
            let photoIndexPath = IndexPath(item: photoIndex, section: 0)
            if let cell = this.collectionView?.cellForItem(at: photoIndexPath) as? PhotoCollectionViewCell {
                cell.update(with: image)
            }
        }
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
            guard let this = self else {
                log(error: "'self' is nil")
                return
            }
            switch result {
            case .success(let photos):
                log(info: "Successfully got \(photos.count) photos")
                this.photoDataSource.photos = photos

            case .failure(let error):
                log(warning: "\(error)")
                this.photoDataSource.photos.removeAll()
            }
            this.collectionView?.reloadData()
        }
    }

}
