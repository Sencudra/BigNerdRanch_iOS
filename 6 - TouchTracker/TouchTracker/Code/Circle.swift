//
//  Circle.swift
//  TouchTracker
//
//  Created by Vladislav Tarasevich on 01.04.2020.
//  Copyright © 2020 Vladislav Tarasevich. All rights reserved.
//

import UIKit

// MARK: - Types

struct Circle {
    var center = CGPoint.zero
    var radius = CGFloat.zero
}

// MARK: - Circle extensions

extension Circle {

    mutating func updateWith(firstTouchLocation firstLocation: CGPoint, secondTouchLocation secondLocation: CGPoint) {
        self.center = CGPoint(x: (firstLocation.x + secondLocation.x) / 2, y: (firstLocation.y + secondLocation.y) / 2)
        self.radius = CGFloat(sqrt(pow(firstLocation.x - secondLocation.x, 2) + pow(firstLocation.y - secondLocation.y, 2))) / 2
    }

}

// MARK: - Circle extension Hashable

extension Circle: Hashable {
    static func == (lhs: Circle, rhs: Circle) -> Bool {
        return lhs.center == rhs.center && lhs.radius == rhs.radius
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(center.x)
        hasher.combine(center.y)
        hasher.combine(radius)
    }
}
