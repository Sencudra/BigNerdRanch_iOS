//
//  PhotoCollectionViewCell.swift
//  Photorama
//
//  Created by Vladislav Tarasevich on 13.04.2020.
//  Copyright © 2020 Vladislav Tarasevich. All rights reserved.
//

import UIKit

final class PhotoCollectionViewCell: UICollectionViewCell {

    // MARK: - Outlets

    @IBOutlet private var imageView: UIImageView?
    @IBOutlet private var spinner: UIActivityIndicatorView?

    // MARK: - Overrides

    override func awakeFromNib() {
        super.awakeFromNib()

        update(with: nil)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        update(with: nil)
    }

    // MARK: - Methods

    func update(with image: UIImage?) {
        if let image = image {
            spinner?.stopAnimating()
            imageView?.image = image
        } else {
            spinner?.startAnimating()
            imageView?.image = nil
        }
    }

}
