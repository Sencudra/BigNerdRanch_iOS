//
//  PhotoStore.swift
//  Photorama
//
//  Created by Vladislav Tarasevich on 12.04.2020.
//  Copyright © 2020 Vladislav Tarasevich. All rights reserved.
//

import Foundation
import UIKit

enum PhotosResult {
    case success([Photo])
    case failure(Error)
}

enum ImageResult {
    case success(UIImage)
    case failure(Error)
}

enum PhotoStoreError: Error {
    case unexpected
    case imageCreation
}

class PhotoStore {

    // MARK: - Private properties

    private let imageStore = ImageStore()

    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()

    // MARK: - Methods

    func fetchPhotos(for method: Method, completionHandler: @escaping (PhotosResult) -> Void) {
        let url = FlickrAPI.photosURL(for: method)

        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) { [weak self] (data, response, error) -> Void in
            guard let this = self else {
                completionHandler(.failure(PhotoStoreError.unexpected))
                return
            }

            if let response = response as? HTTPURLResponse {
                log(info: "\(response.statusCode)")
                log(info: "\(response.allHeaderFields)")
            }

            let result = this.processPhotosRequest(data: data, error: error)

            OperationQueue.main.addOperation {
                completionHandler(result)
            }
        }
        task.resume()
    }

    func fetchImage(for photo: Photo, completionHandler: @escaping (ImageResult) -> Void) {

        if let image = imageStore.getImage(forKey: photo.photoIdentifier) {
            OperationQueue.main.addOperation {
                completionHandler(.success(image))
            }
            return
        }

        let request = URLRequest(url: photo.remoteURL)
        let task = session.dataTask(with: request) { [weak self] (data, _, error) -> Void in
            guard let this = self else {
                completionHandler(.failure(PhotoStoreError.unexpected))
                return
            }

            let result = this.processImageRequest(data: data, error: error)

            if case .success(let image) = result {
                this.imageStore.set(image, forKey: photo.photoIdentifier)
            }

            OperationQueue.main.addOperation {
                completionHandler(result)
            }
        }
        task.resume()
    }

    // MARK: - Private methods

    private func processPhotosRequest(data: Data?, error: Error?) -> PhotosResult {
        guard let jsonData = data else {
            guard let error = error else {
                return .failure(PhotoStoreError.unexpected)
            }
            return .failure(error)
        }
        return FlickrAPI.photos(fromJSON: jsonData)
    }

    private func processImageRequest(data: Data?, error: Error?) -> ImageResult {
        guard let data = data else {
            guard let error = error else {
                return .failure(PhotoStoreError.unexpected)
            }
            return .failure(error)
        }

        guard let image = UIImage(data: data) else {
            return .failure(PhotoStoreError.imageCreation)
        }
        return .success(image)
    }

}
