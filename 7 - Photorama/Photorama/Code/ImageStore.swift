//
//  ImageStore.swift
//  Homepwner
//
//  Created by Vladislav Tarasevich on 25.03.2020.
//  Copyright © 2020 Vladislav Tarasevich. All rights reserved.
//

import UIKit

final class ImageStore {

    // MARK: - Properties

    let cache = NSCache<NSString, UIImage>()

    // MARK: - Methods

    func set(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
        storeToDisk(image, forKey: key)
    }

    func getImage(forKey key: String) -> UIImage? {
        if let existingImage = cache.object(forKey: key as NSString) {
            return existingImage
        }
        guard let imageFromDisk = getImageFromDisk(forKey: key) else { return nil }
        cache.setObject(imageFromDisk, forKey: key as NSString)
        return imageFromDisk
    }

    func deleteImage(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
        removeImageFromDisk(forKey: key)
    }

    // MARK: - Private methods

    private func imageURL(forKey key: String) -> URL {
        let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return directoryURL.appendingPathComponent(key)
    }

    private func storeToDisk(_ image: UIImage, forKey key: String) {
        let url = imageURL(forKey: key)
        guard let data = image.jpegData(compressionQuality: 0.5), (try? data.write(to: url, options: [.atomic])) != nil else {
                log(error: "Unable to write <\(url)>")
                return
        }
    }

    private func getImageFromDisk(forKey key: String) -> UIImage? {
        let url = imageURL(forKey: key)
        return UIImage(contentsOfFile: url.path)
    }

    private func removeImageFromDisk(forKey key: String) {
        let url = imageURL(forKey: key)
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            log(info: "\(error). Unable to remove \(url)")
        }
    }

}
