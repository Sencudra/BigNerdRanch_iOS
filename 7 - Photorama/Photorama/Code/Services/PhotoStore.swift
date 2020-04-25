//
//  PhotoStore.swift
//  Photorama
//
//  Created by Vladislav Tarasevich on 12.04.2020.
//  Copyright © 2020 Vladislav Tarasevich. All rights reserved.
//

import UIKit
import CoreData

// MARK: - Results

enum PhotosResult {
    case success([Photo])
    case failure(Error)
}

enum TagsResult {
    case success([Tag])
    case failure(Error)
}

enum ImageResult {
    case success(UIImage)
    case failure(Error)
}

// MARK: - Errors

enum PhotoStoreError: Error {
    case unexpected
    case imageCreation
}

// MARK: - Implementation

class PhotoStore {

    // MARK: - Properties

    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Photorama")
        container.loadPersistentStores { _, error in
            if let error = error {
                log(error: "Error settings up Core Data \(error)")
            }
        }
        return container
    }()

    // MARK: - Private properties

    private let imageStore = ImageStore()

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

    func fetchAllTags(completionHandler: @escaping (TagsResult) -> Void) {
        let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
        let sortByName = NSSortDescriptor(key: #keyPath(Tag.name), ascending: true)

        fetchRequest.sortDescriptors = [sortByName]

        let viewContext = persistentContainer.viewContext
        viewContext.perform {
            do {
                let allTags = try fetchRequest.execute()
                completionHandler(.success(allTags))
            } catch {
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

            this.processPhotosRequest(for: method, data: data, error: error) { result in
                OperationQueue.main.addOperation {
                    completionHandler(result)
                }
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

    private func processPhotosRequest(for method: Method,
                                      data: Data?,
                                      error: Error?,
                                      completionHandler: @escaping (PhotosResult) -> Void) {
        guard let jsonData = data else {
            guard let error = error else {
                completionHandler(.failure(PhotoStoreError.unexpected))
                return
            }
            completionHandler(.failure(error))
            return
        }

        persistentContainer.performBackgroundTask { [weak self] context in
            guard let this = self else {
                log(error: "Unexpectedly unwrapped nil")
                return
            }

            let result = FlickrAPI.photos(for: method, fromJSON: jsonData, into: this.persistentContainer.viewContext)

            do {
                try context.save()
            } catch {
                log(error: "Error saving to Core Data: \(error)")
                completionHandler(.failure(error))
                return
            }

            switch result {
            case .success(let photos):
                let photoIDs = photos.map { $0.objectID }
                let viewContext = this.persistentContainer.viewContext

                let viewContextPhotos = photoIDs.map { viewContext.object(with: $0) } as? [Photo]

                guard let photos = viewContextPhotos else {
                    return
                }
                completionHandler(.success(photos))

            case .failure:
                completionHandler(result)

            }
        }
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
