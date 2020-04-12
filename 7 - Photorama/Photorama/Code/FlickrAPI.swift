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
}

struct FlickrAPI {

    // MARK: - Types

    // MARK: - Static properties

    static var interestingPhotosURL: URL {
        return flickrURL(method: .interestingPhotos, parameters: ["extras": "url_h,date_taken"])
    }

    // MARK: - Private static properties

    private static let baseURL = "https://api.flickr.com/services/rest"

    // Hide this somehow
    private static let apiKey = Keys.get(forKind: .flickr)

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

}
