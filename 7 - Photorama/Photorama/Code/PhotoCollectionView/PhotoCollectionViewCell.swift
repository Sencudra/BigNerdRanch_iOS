//
//  PhotoCollectionViewCell.swift
//  Photorama
//
//  Created by Vladislav Tarasevich on 13.04.2020.
//  Copyright © 2020 Vladislav Tarasevich. All rights reserved.
//

import UIKit

final class PhotoCollectionViewCell: UICollectionViewCell {

    // MARK: - Type

    struct ViewModel {
        let image: UIImage
        let viewCount: Int
    }

    // MARK: - Outlets

    @IBOutlet private var imageView: UIImageView?
    @IBOutlet private var spinner: UIActivityIndicatorView?
    @IBOutlet private var viewCountLabel: UILabel?

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

    func update(with model: ViewModel?) {
        if let model = model {
            spinner?.stopAnimating()
            imageView?.image = model.image
            viewCountLabel?.text = "\(model.viewCount)"

        } else {
            spinner?.startAnimating()
            imageView?.image = nil
            viewCountLabel?.text = ""
        }
    }

}
