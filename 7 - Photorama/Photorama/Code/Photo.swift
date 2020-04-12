//
//  Photo.swift
//  Photorama
//
//  Created by Vladislav Tarasevich on 12.04.2020.
//  Copyright © 2020 Vladislav Tarasevich. All rights reserved.
//

import Foundation

class Photo {

    // MARK: - Properties

    let title: String
    let remoteURL: URL
    let photoIdentifier: String
    let dateTaken: Date

    // MARK: - Init

    init(title: String, remoteURL: URL, photoIdentifier: String, dateTaken: Date) {
        self.title = title
        self.remoteURL = remoteURL
        self.photoIdentifier = photoIdentifier
        self.dateTaken = dateTaken
    }

}

// MARK: - Photo extension

extension Photo: Equatable {

    static func == (lhs: Photo, rhs: Photo) -> Bool {
        return lhs.photoIdentifier == rhs.photoIdentifier
    }

}
