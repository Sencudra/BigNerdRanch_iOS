//
//  PhotoDataSource.swift
//  Photorama
//
//  Created by Vladislav Tarasevich on 12.04.2020.
//  Copyright © 2020 Vladislav Tarasevich. All rights reserved.
//

import UIKit

class PhotoDateSource: NSObject, UICollectionViewDataSource {

    // MARK: - Photo

    var photos = [Photo]()

    // MARK: - Methods

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = "PhotoCollectionViewCell"
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? PhotoCollectionViewCell else {
            log(error: "Unable to get photoCellectionViewCell")
            return UICollectionViewCell()
        }
        return cell
    }

}
