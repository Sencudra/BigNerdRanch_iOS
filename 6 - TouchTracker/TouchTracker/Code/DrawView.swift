//
//  DrawView.swift
//  TouchTracker
//
//  Created by Vladislav Tarasevich on 31.03.2020.
//  Copyright © 2020 Vladislav Tarasevich. All rights reserved.
//

import UIKit

final class DrawView: UIView {

    // MARK: - Properties

    var currentLines = [NSValue:Line]()
    var finishedLines = [Line]()

    // MARK: - Private properties

    @IBInspectable
    private var lineThickness: CGFloat = 10 {
        didSet {
            setNeedsDisplay()
        }
    }

    // MARK: - Overrides

    override func draw(_ rect: CGRect) {
        for line in finishedLines {
            line.color.setStroke()
            stroke(line)
        }

        for (_, line) in currentLines {
            line.color.setStroke()
            stroke(line)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        log(info: "Touch!")

        for touch in touches {
            let location = touch.location(in: self)
            let newLine = Line(start: location, end: location)
            let key = NSValue(nonretainedObject: touch)
            currentLines[key] = newLine
        }

        setNeedsDisplay()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        log(info: "Moved!")

        for touch in touches {
            let key = NSValue(nonretainedObject: touch)
            currentLines[key]?.end = touch.location(in: self)
        }

        setNeedsDisplay()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        log(info: "Ended!")

        for touch in touches {
            let key = NSValue(nonretainedObject: touch)
            guard var line = currentLines[key] else {
                return
            }

            line.end = touch.location(in: self)

            finishedLines.append(line)
            currentLines.removeValue(forKey: key)
        }

        setNeedsDisplay()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        log(info: "Cancelled!")

        currentLines.removeAll()

        setNeedsDisplay()
    }

    // MARK: - Private methods

    private func stroke(_ line: Line) {
        let path = UIBezierPath()
        path.lineWidth = lineThickness
        path.lineCapStyle = .round

        path.move(to: line.start)
        path.addLine(to: line.end)
        path.stroke()
    }

}
