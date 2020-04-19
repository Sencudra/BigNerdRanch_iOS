//
//  FlipBookCollectionVIewLayout.swift
//  Photorama
//
//  Created by Vladislav Tarasevich on 19.04.2020.
//  Copyright © 2020 Vladislav Tarasevich. All rights reserved.
//

import UIKit

final class FlipBookFlowLayout: UICollectionViewFlowLayout {

    // MARK: - Overrides

    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }

    // MARK: - Private properties

    private var numberOfImages = 0

    private var contentHeight: CGFloat {
        return collectionView!.bounds.height
    }

    private var contentWidth: CGFloat {
        return collectionView!.bounds.width * CGFloat(numberOfImages)
    }

    // MARK: - Overrides

    override func prepare() {
        guard let collectionView = collectionView else {
            log(error: "Got collection view is nil")
            return
        }
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false

        numberOfImages = collectionView.numberOfItems(inSection: 0)
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()

        for i in 0..<numberOfImages {
            let indexPath = IndexPath(item: i, section: 0)

            if let attributes = layoutAttributesForItem(at: indexPath) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let collectionView = collectionView else {
            return nil
        }

        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        let frame = CGRect(x: CGFloat(0 - collectionView.bounds.width / 2) + collectionView.contentOffset.x,
                          y: .zero,
                          width: collectionView.bounds.width,
                          height: collectionView.bounds.height)
        attributes.frame = frame

        let ratio = getRatio(collectionView: collectionView, indexPath: indexPath)
        print(ratio)
        let rotation = getRotation(indexPath: indexPath, ratio: min(max(ratio, -1), 1))
        attributes.transform3D = rotation

        if indexPath.row == 0 {
            attributes.zIndex = Int.max
        }

        return attributes
    }

    // MARK: - Private methods

    private func getRotation(indexPath: IndexPath, ratio: CGFloat) -> CATransform3D {
        var transform = CATransform3DIdentity
        transform.m34 = 1.0 / -3000

        let angle = getAngle(indexPath: indexPath, ratio: ratio)
        return CATransform3DRotate(transform, angle, 0, 1, 0)
    }

    func getAngle(indexPath: IndexPath, ratio: CGFloat) -> CGFloat {
        return ratio * CGFloat(Double.pi / 2)
    }

    func getRatio(collectionView: UICollectionView, indexPath: IndexPath) -> CGFloat {
        let page = CGFloat(indexPath.item)
        return CGFloat(page - (collectionView.contentOffset.x / collectionView.bounds.width))
    }

}
