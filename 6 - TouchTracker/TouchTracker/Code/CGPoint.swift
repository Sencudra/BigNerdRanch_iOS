//
//  CGPoint.swift
//  TouchTracker
//
//  Created by Vladislav Tarasevich on 01.04.2020.
//  Copyright © 2020 Vladislav Tarasevich. All rights reserved.
//

import UIKit

extension CGPoint {

    func distance(to endPoint: CGPoint) -> CGFloat {
        let dx = endPoint.x - self.x
        let dy = endPoint.y - self.y
        return sqrt(pow(dx, 2) + pow(dy, 2))
    }

}
