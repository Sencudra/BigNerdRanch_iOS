//
//  MapPin.swift
//  WorldTrotter
//
//  Created by Vladislav Tarasevich on 11.03.2020.
//  Copyright © 2020 Vladislav Tarasevich. All rights reserved.
//

import Foundation
import MapKit

class MapPinAnnotation: NSObject, MKAnnotation {

    // MARK: - Properties

    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?

    // MARK: - Init

    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }

}

// MARK: - MapPin extensions

extension MapPinAnnotation {

    static var home: MapPinAnnotation {
        let latitude = CLLocationDegrees(floatLiteral: 53.881161)
        let longitude = CLLocationDegrees(floatLiteral: 27.513395)
        let coordintation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        return MapPinAnnotation(coordinate: coordintation, title: "Home", subtitle: "Sweet Home!")
    }

    static var now: MapPinAnnotation {
        let latitude = CLLocationDegrees(floatLiteral: 55.848089)
        let longitude = CLLocationDegrees(floatLiteral: 37.369537)
        let coordintation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        return MapPinAnnotation(coordinate: coordintation, title: "Now", subtitle: "Not Sweet Home!")
    }

    static var paradise: MapPinAnnotation {
        let latitude = CLLocationDegrees(floatLiteral: 10.937541)
        let longitude = CLLocationDegrees(floatLiteral: 108.189901)
        let coordintation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        return MapPinAnnotation(coordinate: coordintation, title: "Paradise", subtitle: "Just Best!")
    }

    static var all: [MapPinAnnotation] {
        return [
            .home,
            .now,
            .paradise
        ]
    }

}
