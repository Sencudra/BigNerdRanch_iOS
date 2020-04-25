//
//  Photo+CoreDataProperties.swift
//  Photorama
//
//  Created by Vladislav Tarasevich on 25.04.2020.
//  Copyright © 2020 Vladislav Tarasevich. All rights reserved.
//
//

import Foundation
import CoreData

extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var dateTaken: Date?
    @NSManaged public var method: String?
    @NSManaged public var photoID: String?
    @NSManaged public var remoteURL: NSURL?
    @NSManaged public var title: String?
    @NSManaged public var views: Int32

}
