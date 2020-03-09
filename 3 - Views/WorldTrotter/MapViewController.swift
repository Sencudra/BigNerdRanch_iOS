//
//  MapViewController.swift
//  WorldTrotter
//
//  Created by Vladislav Tarasevich on 09.03.2020.
//  Copyright © 2020 Vladislav Tarasevich. All rights reserved.
//

import UIKit

final class MapViewController: UIViewController {

    // MARK: - Overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        print("MapViewController loaded is's view!")
    }

    override func viewWillAppear(_ animated: Bool) {
        print("MapViewController: view will appear!")
    }

}
