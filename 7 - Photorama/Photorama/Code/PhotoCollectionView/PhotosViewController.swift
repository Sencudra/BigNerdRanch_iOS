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

    var segementIndex: Int {
        return segmentedControl?.selectedSegmentIndex ?? 0
    }

    // MARK: - Private properties

    private var defaultLayout = UICollectionViewFlowLayout()

    // MARK: - Outlets

    @IBOutlet private var segmentedControl: UISegmentedControl?
    @IBOutlet private var collectionView: UICollectionView?

    // MARK: - Overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout else {
            log(error: "Unable to get layout")
            return
        }
        defaultLayout = layout
        collectionView?.dataSource = photoDataSource
        collectionView?.delegate = self
        requestPhotosFetch(for: .interestingPhotos)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showPhoto":
            if let selectedIndexPath = collectionView?.indexPathsForSelectedItems?.first {
                let photo = photoDataSource.photos[selectedIndexPath.row]

                guard let destinationVC = segue.destination as? PhotoInfoViewController else {
                    log(error: "Unwrapped nil value")
                    return
                }
                destinationVC.photo = photo
                destinationVC.store = photoStore
            }
        default:
            preconditionFailure("Unexpected segue identigier \(segue.identifier ?? "nil")")
        }

    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        collectionView?.collectionViewLayout.invalidateLayout()
    }

    // MARK: - IBActions

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        let method: Method
        switch sender.selectedSegmentIndex {
        case 0:
            method = .interestingPhotos
            collectionView?.collectionViewLayout = defaultLayout

        case 1:
            method = .recentPhotos
            collectionView?.collectionViewLayout = defaultLayout

        case 2:
            method = .recentPhotos
            collectionView?.collectionViewLayout = FlipBookFlowLayout()

        default:
            log(error: "Unknown segment \(sender.selectedSegmentIndex)")
            return
        }
        requestPhotosFetch(for: method)
    }

    // MARK: - Methods

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

extension PhotosViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      let itemWidth = collectionView.bounds.size.width / 2
      return CGSize(width: itemWidth, height: itemWidth)
    }

}
