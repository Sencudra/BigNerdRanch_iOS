//
//  FlickerAPI.swift
//  Photorama
//
//  Created by Vladislav Tarasevich on 11.04.2020.
//  Copyright © 2020 Vladislav Tarasevich. All rights reserved.
//

import Foundation

// MARK: - Types

enum Method: String {
    case interestingPhotos = "flickr.interestingness.getList"
    case recentPhotos = "flickr.photos.getRecent"
}

enum FlickrError: Error {
    case invalidJSON
}

struct FlickrAPI {

    // MARK: - Static properties

    static func photosURL(for method: Method, parameters: [String: String] = ["extras": "url_h,date_taken"]) -> URL {
        return flickrURL(method: method, parameters: parameters)
    }

    // MARK: - Private static properties

    private static let baseURL = "https://api.flickr.com/services/rest"

    private static let apiKey = Keys.get(forKind: .flickr)

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()

    // MARK: - Static methods

    static func photos(fromJSON data: Data) -> PhotosResult {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])

            guard let jsonDictionary = jsonObject as? [AnyHashable: Any],
                  let photos = jsonDictionary["photos"] as? [String: Any],
                  let photosArray = photos["photo"] as? [[String: Any]] else {
                    return .failure(FlickrError.invalidJSON)
            }

            var finalPhotos = [Photo]()
            for jsonPhoto in photosArray {
                guard let photo = Self.photo(fromJSON: jsonPhoto) else {
                    log(warning: "Unable to process json photo <\(jsonPhoto)>")
                    continue
                }
                finalPhotos.append(photo)
            }

            guard !finalPhotos.isEmpty else {
                return .failure(FlickrError.invalidJSON)
            }
            return .success(finalPhotos)
        } catch let error {
            return .failure(error)
        }
    }

    // MARK: - Private static methods

    private static func flickrURL(method: Method, parameters: [String: String]?) -> URL {
        var urlComponents = URLComponents(string: baseURL)!
        var queryItems = [URLQueryItem]()

        let baseParameters = [
            "method": method.rawValue,
            "format": "json",
            "nojsoncallback": "1",
            "api_key": apiKey
        ]

        for (key, value) in baseParameters {
            let item = URLQueryItem(name: key, value: value)
            queryItems.append(item)
        }

        if let additionalParameters = parameters {
            for (key, value) in additionalParameters {
                let item = URLQueryItem(name: key, value: value)
                queryItems.append(item)
            }
        }
        urlComponents.queryItems = queryItems

        log(info: "Make Flickr URL: <\(urlComponents.url?.absoluteString ?? "nil")>")
        return urlComponents.url!
    }

    private static func photo(fromJSON json: [String: Any]) -> Photo? {
        guard let photoIdentifier = json["id"] as? String,
              let title = json["title"] as? String,
              let dateString = json["datetaken"] as? String,
              let photoURLstring = json["url_h"] as? String,
              let remoteURL = URL(string: photoURLstring),
              let dateTaken = dateFormatter.date(from: dateString) else {
                return nil
        }
        return Photo(title: title, remoteURL: remoteURL, photoIdentifier: photoIdentifier, dateTaken: dateTaken)
    }

}
