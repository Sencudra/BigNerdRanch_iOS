//
//  String+MapView.swift
//  WorldTrotter
//
//  Created by Vladislav Tarasevich on 14.03.2020.
//  Copyright © 2020 Vladislav Tarasevich. All rights reserved.
//

import Foundation

extension String {

    enum Localizable {

        enum Map {

            static var standartMode: String {
                return NSLocalizedString("Standart", comment: "Standart map view")
            }

            static var hybridMode: String {
                return NSLocalizedString("Hybrid", comment: "Hybrid map view")
            }

            static var satelliteMode: String {
                return NSLocalizedString("Satellite", comment: "Satellite map view")
            }

        }

    }

}
