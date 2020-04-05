//
//  Line.swift
//  TouchTracker
//
//  Created by Vladislav Tarasevich on 31.03.2020.
//  Copyright © 2020 Vladislav Tarasevich. All rights reserved.
//

import UIKit

struct Line {
    var start = CGPoint.zero
    var end = CGPoint.zero
}

// MARK: - Line extension

extension Line {

    var angle: CGFloat {
        let dx = end.x - start.x
        let dy = end.y - start.y
        let deg = atan2(dx, dy) * 180 / .pi
        return  deg >= 0 ? abs(deg) : deg + 360
    }

    var color: UIColor {
        return UIColor(hue: angle / 360, saturation: 1, brightness: 1, alpha: 1)
    }

}
