//
//  PhotoStore.swift
//  Photorama
//
//  Created by Vladislav Tarasevich on 12.04.2020.
//  Copyright © 2020 Vladislav Tarasevich. All rights reserved.
//

import UIKit
import CoreData

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

    private let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Photorama")
        container.loadPersistentStores { _, error in
            if let error = error {
                log(error: "Error settings up Core Data \(error)")
            }

        }
        return container
    }()

    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()

    // MARK: - Methods

    func fetchAllPhotos(for method: Method, completionHandler: @escaping (PhotosResult) -> Void) {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "\(#keyPath(Photo.method)) == %@", method.rawValue)
        let sortedByDateTaken = NSSortDescriptor(key: #keyPath(Photo.dateTaken), ascending: true)

        fetchRequest.sortDescriptors = [sortedByDateTaken]
        fetchRequest.predicate = predicate

        let viewContext = persistentContainer.viewContext
        viewContext.perform {
            do {
                let allPhotos = try viewContext.fetch(fetchRequest)
                completionHandler(.success(allPhotos))
            } catch let error {
                completionHandler(.failure(error))
            }
        }
    }

    func fetchPhotos(for method: Method, completionHandler: @escaping (PhotosResult) -> Void) {
        let url = FlickrAPI.photosURL(for: method)

        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) { [weak self] (data, _, error) -> Void in
            guard let this = self else {
                completionHandler(.failure(PhotoStoreError.unexpected))
                return
            }

            var result = this.processPhotosRequest(for: method, data: data, error: error)
            if case .success = result {
                do {
                    try this.persistentContainer.viewContext.save()
                } catch let error {
                    result = .failure(error)
                }
            }

            OperationQueue.main.addOperation {
                completionHandler(result)
            }
        }
        task.resume()
    }

    func fetchImage(for photo: Photo, completionHandler: @escaping (ImageResult) -> Void) {
        guard let photoKey = photo.photoID else {
            preconditionFailure("Photo expected to have a photoID.")
        }

        if let image = imageStore.getImage(forKey: photoKey) {
            OperationQueue.main.addOperation {
                completionHandler(.success(image))
            }
            return
        }

        guard let photoURL = photo.remoteURL else {
            preconditionFailure("Photo expected to have a photoID.")
        }

        let request = URLRequest(url: photoURL as URL)
        let task = session.dataTask(with: request) { [weak self] (data, _, error) -> Void in
            guard let this = self else {
                completionHandler(.failure(PhotoStoreError.unexpected))
                return
            }

            let result = this.processImageRequest(data: data, error: error)

            if case .success(let image) = result {
                this.imageStore.set(image, forKey: photoKey)
            }

            OperationQueue.main.addOperation {
                completionHandler(result)
            }
        }
        task.resume()
    }

    // MARK: - Private methods

    private func processPhotosRequest(for method: Method, data: Data?, error: Error?) -> PhotosResult {
        guard let jsonData = data else {
            guard let error = error else {
                return .failure(PhotoStoreError.unexpected)
            }
            return .failure(error)
        }
        return FlickrAPI.photos(for: method, fromJSON: jsonData, into: persistentContainer.viewContext)
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
